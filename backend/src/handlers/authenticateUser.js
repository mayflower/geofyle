const { putItem, getItem } = require('../utils/dynamodb');
const { generateToken } = require('../utils/auth');
const { success, error } = require('../utils/response');

/**
 * Handler for authenticating a user by device ID
 * 
 * @param {Object} event - API Gateway Lambda Proxy Input
 * @returns {Object} API Gateway Lambda Proxy Output
 */
exports.handler = async (event) => {
  try {
    // Parse request body
    const body = JSON.parse(event.body || '{}');
    const { deviceId } = body;
    
    if (!deviceId) {
      return error(400, 'MISSING_DEVICE_ID', 'Device ID is required');
    }
    
    // Check if device exists in the users table
    const usersTable = process.env.USERS_TABLE;
    let user = await getItem(usersTable, deviceId);
    
    // If user doesn't exist, create a new user record
    if (!user) {
      user = {
        deviceId,
        createdAt: new Date().toISOString(),
        lastAuthenticated: new Date().toISOString()
      };
      
      await putItem(usersTable, user);
    } else {
      // Update last authenticated timestamp
      await putItem(usersTable, {
        ...user,
        lastAuthenticated: new Date().toISOString()
      });
    }
    
    // Generate JWT token
    const tokenData = await generateToken(deviceId);
    
    // Return token to the client
    return success(200, tokenData);
  } catch (err) {
    console.error('Error authenticating user:', err);
    return error(500, 'SERVER_ERROR', 'Error during authentication');
  }
};