import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, ScanCommand } from "@aws-sdk/lib-dynamodb";

const client = DynamoDBDocumentClient.from(new DynamoDBClient({}));

export async function handler(event) {
    return GetPlayers(client);
}

export async function GetPlayers(client) {
    const command = new ScanCommand({
        TableName: "Players",
    });
    const response = await client.send(command);
    return response.Items;
}