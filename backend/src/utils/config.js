/**
 * Configuration settings for the GeoFyle application
 */

// API endpoint configuration
const API_CONFIG = {
  // Base API URL to be used by the Flutter frontend app
  API_BASE_URL: process.env.API_BASE_URL || 'https://api.geofyle.com/v1',
  
  // Version of the API
  API_VERSION: 'v1',

  // File configuration from environment variables
  MAX_FILE_SIZE_BYTES: parseInt(process.env.MAX_FILE_SIZE_BYTES || '5242880', 10),
  FILE_RETENTION_DAYS: parseInt(process.env.FILE_RETENTION_DAYS || '30', 10),
  DEFAULT_RADIUS_METERS: parseInt(process.env.DEFAULT_RADIUS_METERS || '100', 10),
};

module.exports = {
  API_CONFIG,
};