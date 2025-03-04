const { getItem, updateItem } = require('../utils/dynamodb');
const { getPresignedDownloadUrl } = require('../utils/s3');
const { success, error } = require('../utils/response');
const { isWithinRange } = require('../utils/geo');

/**
 * Handler for downloading a file
 * 
 * @param {Object} event - API Gateway Lambda Proxy Input
 * @returns {Object} API Gateway Lambda Proxy Output
 */
exports.handler = async (event) => {
  try {
    // Get file ID from path parameters
    const { fileId } = event.pathParameters || {};
    
    // Get user location from query parameters
    const { latitude, longitude } = event.queryStringParameters || {};
    
    if (!fileId) {
      return error(400, 'MISSING_FILE_ID', 'File ID is required');
    }
    
    if (!latitude || !longitude) {
      return error(400, 'MISSING_LOCATION', 'User location (latitude and longitude) is required');
    }
    
    const lat = parseFloat(latitude);
    const lon = parseFloat(longitude);
    
    if (isNaN(lat) || isNaN(lon) || lat < -90 || lat > 90 || lon < -180 || lon > 180) {
      return error(400, 'INVALID_COORDINATES', 'Invalid latitude or longitude values');
    }
    
    // Retrieve file metadata from DynamoDB
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
    
    // Check if user is within range of the file
    const userLocation = { latitude: lat, longitude: lon };
    const fileLocation = fileItem.location;
    const defaultRadius = parseInt(process.env.DEFAULT_RADIUS_METERS || '100');
    
    if (!isWithinRange(userLocation, fileLocation, defaultRadius)) {
      return error(403, 'OUT_OF_RANGE', 'You must be within range of the file to download it');
    }
    
    // Generate presigned download URL
    const filesBucket = process.env.FILES_BUCKET;
    const s3Key = `files/${fileId}`;
    const downloadUrl = await getPresignedDownloadUrl(filesBucket, s3Key);
    
    // Update file metadata: increment download count and extend expiration
    const fileRetentionDays = parseInt(process.env.FILE_RETENTION_DAYS || '30');
    const newExpirationTime = new Date(Date.now() + fileRetentionDays * 24 * 60 * 60 * 1000);
    const newTtl = Math.floor(newExpirationTime.getTime() / 1000);
    
    await updateItem(filesTable, fileId, {
      downloadCount: (fileItem.downloadCount || 0) + 1,
      expirationTime: newExpirationTime.toISOString(),
      ttl: newTtl
    });
    
    // Return download URL
    return success(200, { downloadUrl });
  } catch (err) {
    console.error('Error processing download request:', err);
    return error(500, 'SERVER_ERROR', 'Error processing download request');
  }
};