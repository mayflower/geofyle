const { queryByIndex } = require('../utils/dynamodb');
const { success, error } = require('../utils/response');
const { getNearbyGeohashes, isWithinRange } = require('../utils/geo');
const { formatFileItemResponse } = require('../models/fileItem');

/**
 * Handler for retrieving files near a specified location
 * 
 * @param {Object} event - API Gateway Lambda Proxy Input
 * @returns {Object} API Gateway Lambda Proxy Output
 */
exports.handler = async (event) => {
  try {
    // Get parameters from the query string
    const { latitude, longitude, radius } = event.queryStringParameters || {};
    
    // Validate parameters
    if (!latitude || !longitude) {
      return error(400, 'INVALID_PARAMETERS', 'Latitude and longitude are required');
    }
    
    const lat = parseFloat(latitude);
    const lon = parseFloat(longitude);
    const radiusInMeters = radius ? parseInt(radius) : parseInt(process.env.DEFAULT_RADIUS_METERS || '100');
    
    if (isNaN(lat) || isNaN(lon) || lat < -90 || lat > 90 || lon < -180 || lon > 180) {
      return error(400, 'INVALID_COORDINATES', 'Invalid latitude or longitude values');
    }
    
    if (isNaN(radiusInMeters) || radiusInMeters <= 0) {
      return error(400, 'INVALID_RADIUS', 'Radius must be a positive number');
    }
    
    // Get geohashes for the area to search
    const geohashes = getNearbyGeohashes(lat, lon, radiusInMeters);
    
    // Search for files in each geohash
    const filesTable = process.env.FILES_TABLE;
    const now = Math.floor(Date.now() / 1000);
    let nearbyFiles = [];
    
    // Query each geohash area
    for (const geohash of geohashes) {
      const files = await queryByIndex(filesTable, 'GeohashIndex', 'geohash', geohash);
      nearbyFiles = [...nearbyFiles, ...files];
    }
    
    // Filter out expired files and duplicates (since we may get overlapping geohashes)
    const uniqueFileIds = new Set();
    const userLocation = { latitude: lat, longitude: lon };
    
    const filteredFiles = nearbyFiles
      .filter(file => file.ttl > now) // Remove expired files
      .filter(file => {
        // Remove duplicates
        if (uniqueFileIds.has(file.id)) {
          return false;
        }
        uniqueFileIds.add(file.id);
        return true;
      })
      .filter(file => {
        // Check if file is actually within the radius
        return isWithinRange(
          userLocation,
          file.location,
          radiusInMeters
        );
      })
      .map(formatFileItemResponse); // Format for API response
    
    return success(200, filteredFiles);
  } catch (err) {
    console.error('Error getting nearby files:', err);
    return error(500, 'SERVER_ERROR', 'Error retrieving nearby files');
  }
};