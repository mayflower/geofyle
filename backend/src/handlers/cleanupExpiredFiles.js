const { scanExpiredItems, deleteItem } = require('../utils/dynamodb');
const { deleteFile } = require('../utils/s3');

/**
 * Handler for cleaning up expired files
 * Runs on a schedule (daily)
 * 
 * @param {Object} event - CloudWatch Events event
 * @returns {Object} Result of cleanup operation
 */
exports.handler = async (event) => {
  try {
    console.log('Starting expired files cleanup process');
    
    // Get current timestamp
    const now = Math.floor(Date.now() / 1000);
    
    // Scan DynamoDB for expired files
    const filesTable = process.env.FILES_TABLE;
    const expiredFiles = await scanExpiredItems(filesTable, now);
    
    console.log(`Found ${expiredFiles.length} expired files to clean up`);
    
    if (expiredFiles.length === 0) {
      return { message: 'No expired files to clean up' };
    }
    
    // Delete each expired file from S3 and DynamoDB
    const filesBucket = process.env.FILES_BUCKET;
    const deletionResults = { successful: [], failed: [] };
    
    for (const file of expiredFiles) {
      try {
        // Delete from S3
        const s3Key = `files/${file.id}`;
        await deleteFile(filesBucket, s3Key);
        
        // Delete from DynamoDB
        await deleteItem(filesTable, file.id);
        
        deletionResults.successful.push(file.id);
      } catch (err) {
        console.error(`Error deleting expired file ${file.id}:`, err);
        deletionResults.failed.push({
          id: file.id,
          error: err.message
        });
      }
    }
    
    console.log(`Cleanup completed: ${deletionResults.successful.length} files successfully deleted, ${deletionResults.failed.length} failed`);
    
    return {
      message: `Expired files cleanup completed`,
      deleted: deletionResults.successful.length,
      failed: deletionResults.failed.length,
      details: deletionResults
    };
  } catch (err) {
    console.error('Error in expired files cleanup process:', err);
    throw err;
  }
};