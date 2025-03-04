const { getItem } = require('../utils/dynamodb');
const { success, error } = require('../utils/response');
const { formatFileItemResponse } = require('../models/fileItem');

/**
 * Handler for retrieving file details
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
    
    // Retrieve file from DynamoDB
    const filesTable = process.env.FILES_TABLE;
    const fileItem = await getItem(filesTable, fileId);
    
    if (!fileItem) {
      return error(404, 'FILE_NOT_FOUND', 'File not found');
    }
    
    // Check if file has expired
    const now = Math.floor(Date.now() / 1000);
    if (fileItem.ttl && fileItem.ttl <= now) {
      return error(404, 'FILE_EXPIRED', 'The requested file has expired');
    }
    
    // Return file details
    return success(200, formatFileItemResponse(fileItem));
  } catch (err) {
    console.error('Error getting file details:', err);
    return error(500, 'SERVER_ERROR', 'Error retrieving file details');
  }
};