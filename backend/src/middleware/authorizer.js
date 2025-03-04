const { verifyToken } = require('../utils/auth');

/**
 * Lambda authorizer for API Gateway
 * Validates JWT tokens in the Authorization header
 * 
 * @param {Object} event - API Gateway authorizer event
 * @returns {Object} IAM policy document
 */
exports.handler = async (event) => {
  try {
    // Get token from Authorization header
    const authHeader = event.headers?.Authorization || event.headers?.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return generatePolicy('user', 'Deny', event.methodArn);
    }
    
    const token = authHeader.split(' ')[1];
    
    // Verify token
    const payload = verifyToken(token);
    
    if (!payload) {
      return generatePolicy('user', 'Deny', event.methodArn);
    }
    
    // Token is valid, allow the request
    return generatePolicy(payload.deviceId, 'Allow', event.methodArn, payload);
  } catch (err) {
    console.error('Error in authorizer:', err);
    return generatePolicy('user', 'Deny', event.methodArn);
  }
};

/**
 * Generate IAM policy document
 * 
 * @param {string} principalId - Principal ID (user identifier)
 * @param {string} effect - Allow or Deny
 * @param {string} resource - Resource ARN
 * @param {Object} context - Context to pass to the backend
 * @returns {Object} Policy document
 */
function generatePolicy(principalId, effect, resource, context = {}) {
  const authResponse = {
    principalId
  };
  
  if (effect && resource) {
    const policyDocument = {
      Version: '2012-10-17',
      Statement: [
        {
          Action: 'execute-api:Invoke',
          Effect: effect,
          Resource: resource
        }
      ]
    };
    
    authResponse.policyDocument = policyDocument;
  }
  
  // Pass user info to the backend
  authResponse.context = {
    deviceId: context.deviceId || '',
    ...context
  };
  
  return authResponse;
}