const { S3Client, DeleteObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');
const { PutObjectCommand, GetObjectCommand } = require('@aws-sdk/client-s3');

// Initialize S3 client
const s3Client = new S3Client({});

/**
 * Generate a presigned URL for uploading a file to S3
 * 
 * @param {string} bucket - S3 bucket name
 * @param {string} key - S3 object key
 * @param {string} contentType - File content type
 * @param {number} expiresIn - URL expiration time in seconds (default: 3600)
 * @returns {string} Presigned URL
 */
async function getPresignedUploadUrl(bucket, key, contentType, expiresIn = 3600) {
  const command = new PutObjectCommand({
    Bucket: bucket,
    Key: key,
    ContentType: contentType
  });
  
  return getSignedUrl(s3Client, command, { expiresIn });
}

/**
 * Generate a presigned URL for downloading a file from S3
 * 
 * @param {string} bucket - S3 bucket name
 * @param {string} key - S3 object key
 * @param {number} expiresIn - URL expiration time in seconds (default: 300)
 * @returns {string} Presigned URL
 */
async function getPresignedDownloadUrl(bucket, key, expiresIn = 300) {
  const command = new GetObjectCommand({
    Bucket: bucket,
    Key: key
  });
  
  return getSignedUrl(s3Client, command, { expiresIn });
}

/**
 * Delete a file from S3
 * 
 * @param {string} bucket - S3 bucket name
 * @param {string} key - S3 object key
 * @returns {Promise} S3 delete result
 */
async function deleteFile(bucket, key) {
  const command = new DeleteObjectCommand({
    Bucket: bucket,
    Key: key
  });
  
  return s3Client.send(command);
}

module.exports = {
  getPresignedUploadUrl,
  getPresignedDownloadUrl,
  deleteFile
};