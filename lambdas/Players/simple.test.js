import { test, expect } from 'vitest'
import { GetPlayers } from './index.mjs'
import { mockClient } from 'aws-sdk-client-mock'
import { DynamoDBDocumentClient, ScanCommand } from '@aws-sdk/lib-dynamodb'

const client = mockClient(DynamoDBDocumentClient)

client
    .on(ScanCommand)
    .callsFake(() => {
        return { Items: [{ Id: '1', Name: 'Test' }] }
    })

test('simple test', async () => {
    const items = await GetPlayers(client)
    console.log(items)
    expect(items).length(1)
})