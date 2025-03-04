const { putItem } = require('../utils/dynamodb');
const { getPresignedUploadUrl } = require('../utils/s3');
const { success, error } = require('../utils/response');
const { createFileItem, formatFileItemResponse } = require('../models/fileItem');

/**
 * Handler for uploading a file
 * 
 * @param {Object} event - API Gateway Lambda Proxy Input
 * @returns {Object} API Gateway Lambda Proxy Output
 */
exports.handler = async (event) => {
  try {
    // Parse request body
    const body = JSON.parse(event.body);
    
    // Extract and validate file metadata
    const { name, description, latitude, longitude, retentionHours, contentType, fileSize } = body;
    
    if (!name || !description || !latitude || !longitude || !contentType || !fileSize) {
      return error(400, 'MISSING_PARAMETERS', 'Required parameters are missing');
    }
    
    // Check file size limit
    const maxFileSize = parseInt(process.env.MAX_FILE_SIZE_BYTES || '5242880'); // 5MB
    if (fileSize > maxFileSize) {
      return error(413, 'FILE_TOO_LARGE', `File exceeds the maximum allowed size of ${maxFileSize} bytes`);
    }
    
    // Create file metadata
    const fileData = createFileItem({
      name,
      description,
      size: fileSize,
      mimeType: contentType,
      location: {
        latitude: parseFloat(latitude),
        longitude: parseFloat(longitude)
      },
      retentionHours: retentionHours ? parseInt(retentionHours) : undefined
    });
    
    // Create S3 key using file ID
    const filesBucket = process.env.FILES_BUCKET;
    const s3Key = `files/${fileData.id}`;
    
    // Generate presigned URL for file upload
    const uploadUrl = await getPresignedUploadUrl(filesBucket, s3Key, contentType);
    
    // Store file metadata in DynamoDB
    await putItem(process.env.FILES_TABLE, fileData);
    
    // Return response with file metadata and upload URL
    return success(201, {
      file: formatFileItemResponse(fileData),
      uploadUrl
    });
  } catch (err) {
    console.error('Error processing file upload:', err);
    return error(500, 'SERVER_ERROR', 'Error processing file upload request');
  }
};