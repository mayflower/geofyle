const Joi = require('joi');
const { v4: uuidv4 } = require('uuid');
const { createGeohash } = require('../utils/geo');

/**
 * FileItem schema validation using Joi
 */
const fileItemSchema = Joi.object({
  id: Joi.string().uuid().default(() => uuidv4()),
  name: Joi.string().required(),
  description: Joi.string().required(),
  size: Joi.number().integer().required(),
  mimeType: Joi.string().required(),
  location: Joi.object({
    latitude: Joi.number().min(-90).max(90).required(),
    longitude: Joi.number().min(-180).max(180).required()
  }).required(),
  uploadTime: Joi.date().iso().default(() => new Date().toISOString()),
  expirationTime: Joi.date().iso().required(),
  downloadCount: Joi.number().integer().default(0),
  geohash: Joi.string(),
  ttl: Joi.number().integer()
});

/**
 * Create a new FileItem for storage in DynamoDB
 * 
 * @param {Object} data - File metadata
 * @returns {Object} Validated and normalized file item
 */
function createFileItem(data) {
  // Calculate retention time
  const now = new Date();
  const retentionHours = data.retentionHours || 24 * parseInt(process.env.FILE_RETENTION_DAYS || '30');
  const expirationTime = new Date(now.getTime() + retentionHours * 60 * 60 * 1000);
  
  // Calculate TTL (Unix timestamp)
  const ttl = Math.floor(expirationTime.getTime() / 1000);
  
  // Create geohash for location-based queries
  const geohash = createGeohash(data.location.latitude, data.location.longitude);
  
  // Validate and generate the complete file item
  const { error, value } = fileItemSchema.validate({
    ...data,
    expirationTime: expirationTime.toISOString(),
    geohash,
    ttl
  });
  
  if (error) {
    throw new Error(`Invalid file data: ${error.message}`);
  }
  
  return value;
}

/**
 * Format FileItem for API response
 * 
 * @param {Object} item - DynamoDB file item
 * @returns {Object} Formatted file item for API
 */
function formatFileItemResponse(item) {
  // Return only the fields specified in the API schema
  const { id, name, description, size, mimeType, location, uploadTime, expirationTime, downloadCount } = item;
  
  return {
    id,
    name,
    description,
    size,
    mimeType,
    location,
    uploadTime,
    expirationTime,
    downloadCount
  };
}

module.exports = {
  createFileItem,
  formatFileItemResponse
};