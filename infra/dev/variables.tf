variable "env" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "tfstate-bucket" {
  type    = string
  default = "tfstate-bucket"
}

variable "lambda-bucket" {
  type    = string
  default = "lambda-bucket"
}

variable "dynamodb_backend_lock" {
  type    = string
  default = "tfstate_backend_lock_table"
}

variable "dynamodb_players" {
  type    = string
  default = "Player"
}

variable "lambda_policy_name" {
  type    = string
  default = "S3_lambda_access_policy"
}

variable "lambda_role_name" {
  type    = string
  default = "S3_lambda_access_role"
}

variable "lambda_name" {
  type    = string
  default = "Lambda_players"
}

variable "lambda_handler" {
  type    = string
  default = "index.handler"
}

variable "path_lambda_source_code" {
  type    = string
  default = "${path.root}/lambdas/Players"
}

variable "path_lambda_output_code" {
  type    = string
  default = "lambda_function_code"
}

variable "player_api_name" {
  type    = string
  default = "PlayerAPI"
}

variable "apigw_player_path" {
  type    = string
  default = "player_GW"
}