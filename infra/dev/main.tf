#################### Providers and Backend ######################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # # NOTE: Uncomment the backend config code after the first deployment, as the tfstate cannot be stored in a bucket that is not yet created
  # backend "s3" {
  #   bucket         = "tfstate-bucket-pro"
  #   key            = "tfstate/terraform.tfstate"
  #   region         = "eu-west-1"
  #   dynamodb_table = "tfstate_backend_lock_table"
  # }
}

provider "aws" {
  region = var.region
}

#################### Dynamo DB ######################

resource "aws_dynamodb_table" "tfstate_backend_lock_table" {
  name         = "${var.dynamodb_backend_lock}-${var.env}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_dynamodb_table" "players_table" {
  name         = var.dynamodb_players
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "playerId"

  attribute {
    name = "playerId"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }
}

#################### S3 Buckets ######################

resource "aws_s3_bucket" "tfstate_bucket" {
  bucket = "${var.tfstate-bucket}-${var.env}"

  dynamic "server_side_encryption" {
    for_each = [{}]

    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
  }

  dynamic "versioning" {
    for_each = [{}]

    content {
      enabled = true
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate_bucket_public_access_block" {
  bucket = aws_s3_bucket.tfstate_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.lambda-bucket}-${var.env}"

  dynamic "versioning" {
    for_each = [{}]

    content {
      enabled = true
    }
  }
}

resource "aws_s3_bucket_public_access_block" "lambda_bucket_public_access_block" {
  bucket = aws_s3_bucket.lambda_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload lambda files to S3
data "archive_file" "lambda_files" {
  type        = "zip"
  source_file = var.path_lambda_source_code
  output_path = "${var.path_lambda_output_code}.zip"
}

resource "aws_s3_object" "lambda_source" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = var.path_lambda_output_code
  source = data.archive_file.lambda_files.output_path

  etag = filemd5(data.archive_file.lambda_files.output_path)
}

#################### Lambda ######################

data "aws_iam_policy_document" "assume_role_lambda" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.lambda_role_name}-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
}

resource "aws_lambda_function" "lambda_function_player" {
  s3_bucket        = aws_s3_bucket.lambda_bucket.id
  s3_key           = var.path_lambda_output_code
  function_name    = "${var.lambda_name}-${var.env}"
  role             = aws_iam_role.lambda_role.arn
  handler          = var.lambda_handler
  source_code_hash = data.archive_file.lambda_files.output_base64sha256
  runtime          = "nodejs18.x"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.players_table.name
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

#################### API Gateway ######################

resource "aws_api_gateway_rest_api" "player_api" {
  name = var.player_api_name
}

resource "aws_api_gateway_resource" "apigw_player_resource" {
  rest_api_id = aws_api_gateway_rest_api.player_api.id
  parent_id   = aws_api_gateway_rest_api.player_api.root_resource_id
  path_part   = var.apigw_player_path
}

resource "aws_api_gateway_method" "player_method" {
  rest_api_id   = aws_api_gateway_rest_api.player_api.id
  resource_id   = aws_api_gateway_resource.apigw_player_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "player_integration" {
  rest_api_id = aws_api_gateway_rest_api.player_api.id
  resource_id = aws_api_gateway_resource.apigw_player_resource.id
  http_method = aws_api_gateway_method.player_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function_player.invoke_arn
}

resource "aws_lambda_permission" "player_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function_player.function_name
  principal     = "apigateway.amazonaws.com"
}
