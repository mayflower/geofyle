const geolib = require('geolib');

/**
 * Creates a simple geohash for DynamoDB indexing
 * This is a simplified version for demonstration - production systems
 * might use a more sophisticated geohashing library
 * 
 * @param {number} lat - Latitude
 * @param {number} lon - Longitude
 * @param {number} precision - Precision of geohash (default: 5)
 * @returns {string} Geohash
 */
function createGeohash(lat, lon, precision = 5) {
  // Validate inputs
  if (typeof lat !== 'number' || typeof lon !== 'number') {
    throw new Error('Latitude and longitude must be numbers');
  }
  
  if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
    throw new Error('Invalid coordinates: lat must be between -90 and 90, lon between -180 and 180');
  }

  // Convert latitude and longitude to fixed precision strings
  // This creates a simple grid-based geohash for our purpose
  const latStr = (lat + 90).toFixed(precision);
  const lonStr = (lon + 180).toFixed(precision);
  
  // Combine to create geohash
  return `${latStr}:${lonStr}`;
}

/**
 * Gets nearby geohashes for querying
 * 
 * @param {number} lat - Latitude
 * @param {number} lon - Longitude
 * @param {number} radiusInMeters - Search radius
 * @returns {string[]} Array of nearby geohashes
 */
function getNearbyGeohashes(lat, lon, radiusInMeters = 100) {
  // For a simple implementation, we'll create geohashes for points in cardinal directions
  // at the radius distance, plus the center point
  const points = [
    { latitude: lat, longitude: lon }, // Center
    ...geolib.getPointsAtDistance(
      { latitude: lat, longitude: lon },
      radiusInMeters,
      8 // Get points in 8 directions
    )
  ];
  
  // Convert to geohashes
  return [...new Set(points.map(p => createGeohash(p.latitude, p.longitude)))];
}

/**
 * Calculate distance between two coordinates in meters
 * 
 * @param {Object} point1 - First point with latitude and longitude
 * @param {Object} point2 - Second point with latitude and longitude
 * @returns {number} Distance in meters
 */
function calculateDistance(point1, point2) {
  return geolib.getDistance(
    { latitude: point1.latitude, longitude: point1.longitude },
    { latitude: point2.latitude, longitude: point2.longitude }
  );
}

/**
 * Check if a point is within range of another point
 * 
 * @param {Object} point1 - First point with latitude and longitude
 * @param {Object} point2 - Second point with latitude and longitude
 * @param {number} rangeInMeters - Range in meters
 * @returns {boolean} True if within range
 */
function isWithinRange(point1, point2, rangeInMeters) {
  const distance = calculateDistance(point1, point2);
  return distance <= rangeInMeters;
}

module.exports = {
  createGeohash,
  getNearbyGeohashes,
  calculateDistance,
  isWithinRange
};