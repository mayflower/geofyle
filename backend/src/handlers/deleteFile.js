const { getItem, deleteItem } = require('../utils/dynamodb');
const { deleteFile: deleteS3File } = require('../utils/s3');
const { error } = require('../utils/response');

/**
 * Handler for deleting a file
 * 
 * @param {Object} event - API Gateway Lambda Proxy Input
 * @returns {Object} API Gateway Lambda Proxy Output
 */
exports.handler = async (event) => {
  try {
    // Get file ID from path parameters
    const { fileId } = event.pathParameters || {};
    
    if (!fileId) {
      return error(400, 'MISSING_FILE_ID', 'File ID is required');
    }
    
    // Check if file exists
    const filesTable = process.env.FILES_TABLE;
    const fileItem = await getItem(filesTable, fileId);
    
    if (!fileItem) {
      return error(404, 'FILE_NOT_FOUND', 'File not found');
    }
    
    // Delete file from S3
    const filesBucket = process.env.FILES_BUCKET;
    const s3Key = `files/${fileId}`;
    
    await deleteS3File(filesBucket, s3Key);
    
    // Delete file metadata from DynamoDB
    await deleteItem(filesTable, fileId);
    
    // Return success response with no content
    return {
      statusCode: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'
      }
    };
  } catch (err) {
    console.error('Error deleting file:', err);
    return error(500, 'SERVER_ERROR', 'Error deleting file');
  }
};