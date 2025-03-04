const crypto = require('crypto');
const { getItem, putItem } = require('./dynamodb');

// For demo purposes, we're using a simple JWT-like token
// In production, you would use a proper JWT library with better security

/**
 * Generate a token for a user
 * 
 * @param {string} deviceId - Device identifier
 * @param {number} expiresInHours - Token expiration time in hours
 * @returns {Object} Token data
 */
async function generateToken(deviceId, expiresInHours = 24) {
  // Create token payload
  const now = new Date();
  const expiresAt = new Date(now.getTime() + expiresInHours * 60 * 60 * 1000);
  
  const payload = {
    deviceId,
    iat: Math.floor(now.getTime() / 1000),
    exp: Math.floor(expiresAt.getTime() / 1000)
  };
  
  // Create token parts
  const header = { typ: 'JWT', alg: 'HS256' };
  const encodedHeader = Buffer.from(JSON.stringify(header)).toString('base64').replace(/=/g, '');
  const encodedPayload = Buffer.from(JSON.stringify(payload)).toString('base64').replace(/=/g, '');
  
  // Sign the token
  const signature = crypto
    .createHmac('sha256', process.env.JWT_SECRET || 'dev-secret-key')
    .update(`${encodedHeader}.${encodedPayload}`)
    .digest('base64')
    .replace(/=/g, '');
  
  // Create the complete token
  const token = `${encodedHeader}.${encodedPayload}.${signature}`;
  
  return {
    token,
    expiresAt: expiresAt.toISOString()
  };
}

/**
 * Verify a token
 * 
 * @param {string} token - Token to verify
 * @returns {Object|null} Decoded payload or null if invalid
 */
function verifyToken(token) {
  try {
    // Split token parts
    const [encodedHeader, encodedPayload, signature] = token.split('.');
    
    // Verify signature
    const expectedSignature = crypto
      .createHmac('sha256', process.env.JWT_SECRET || 'dev-secret-key')
      .update(`${encodedHeader}.${encodedPayload}`)
      .digest('base64')
      .replace(/=/g, '');
    
    if (signature !== expectedSignature) {
      return null;
    }
    
    // Decode payload
    const payload = JSON.parse(Buffer.from(encodedPayload, 'base64').toString());
    
    // Check expiration
    const now = Math.floor(Date.now() / 1000);
    if (payload.exp < now) {
      return null;
    }
    
    return payload;
  } catch (err) {
    return null;
  }
}

module.exports = {
  generateToken,
  verifyToken
};