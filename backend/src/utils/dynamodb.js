const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { 
  DynamoDBDocumentClient, 
  GetCommand, 
  PutCommand, 
  UpdateCommand, 
  DeleteCommand, 
  QueryCommand, 
  ScanCommand 
} = require('@aws-sdk/lib-dynamodb');

// Initialize DynamoDB client
const client = new DynamoDBClient({});
const documentClient = DynamoDBDocumentClient.from(client);

/**
 * Get a single item from DynamoDB by id
 * 
 * @param {string} tableName - DynamoDB table name
 * @param {string} id - Item id
 * @returns {Promise<Object>} Item data or null if not found
 */
async function getItem(tableName, id) {
  const params = {
    TableName: tableName,
    Key: { id }
  };
  
  const { Item } = await documentClient.send(new GetCommand(params));
  return Item || null;
}

/**
 * Put an item in DynamoDB
 * 
 * @param {string} tableName - DynamoDB table name
 * @param {Object} item - Item to store
 * @returns {Promise<Object>} DynamoDB put result
 */
async function putItem(tableName, item) {
  const params = {
    TableName: tableName,
    Item: item
  };
  
  return documentClient.send(new PutCommand(params));
}

/**
 * Update an item in DynamoDB
 * 
 * @param {string} tableName - DynamoDB table name
 * @param {string} id - Item id
 * @param {Object} updates - Update expressions and values
 * @returns {Promise<Object>} Updated item
 */
async function updateItem(tableName, id, updates) {
  const updateExpression = 'set ' + Object.keys(updates)
    .map(key => `#${key} = :${key}`)
    .join(', ');
    
  const expressionAttributeNames = Object.keys(updates)
    .reduce((acc, key) => ({ ...acc, [`#${key}`]: key }), {});
    
  const expressionAttributeValues = Object.entries(updates)
    .reduce((acc, [key, value]) => ({ ...acc, [`:${key}`]: value }), {});
  
  const params = {
    TableName: tableName,
    Key: { id },
    UpdateExpression: updateExpression,
    ExpressionAttributeNames: expressionAttributeNames,
    ExpressionAttributeValues: expressionAttributeValues,
    ReturnValues: 'ALL_NEW'
  };
  
  const { Attributes } = await documentClient.send(new UpdateCommand(params));
  return Attributes;
}

/**
 * Delete an item from DynamoDB
 * 
 * @param {string} tableName - DynamoDB table name
 * @param {string} id - Item id
 * @returns {Promise<Object>} DynamoDB delete result
 */
async function deleteItem(tableName, id) {
  const params = {
    TableName: tableName,
    Key: { id }
  };
  
  return documentClient.send(new DeleteCommand(params));
}

/**
 * Query items by GSI
 * 
 * @param {string} tableName - DynamoDB table name
 * @param {string} indexName - GSI name
 * @param {string} keyName - Index key name
 * @param {string} keyValue - Index key value
 * @returns {Promise<Array>} Query results
 */
async function queryByIndex(tableName, indexName, keyName, keyValue) {
  const params = {
    TableName: tableName,
    IndexName: indexName,
    KeyConditionExpression: `#${keyName} = :value`,
    ExpressionAttributeNames: {
      [`#${keyName}`]: keyName
    },
    ExpressionAttributeValues: {
      ':value': keyValue
    }
  };
  
  const { Items } = await documentClient.send(new QueryCommand(params));
  return Items || [];
}

/**
 * Scan DynamoDB table for expired items
 * 
 * @param {string} tableName - DynamoDB table name
 * @param {number} nowTimestamp - Current timestamp for comparison
 * @returns {Promise<Array>} Expired items
 */
async function scanExpiredItems(tableName, nowTimestamp) {
  const params = {
    TableName: tableName,
    FilterExpression: '#ttl <= :now',
    ExpressionAttributeNames: {
      '#ttl': 'ttl'
    },
    ExpressionAttributeValues: {
      ':now': nowTimestamp
    }
  };
  
  const { Items } = await documentClient.send(new ScanCommand(params));
  return Items || [];
}

module.exports = {
  getItem,
  putItem,
  updateItem,
  deleteItem,
  queryByIndex,
  scanExpiredItems
};