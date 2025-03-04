# GeoFyle Backend

A serverless AWS backend for GeoFyle, a location-based file sharing application. GeoFyle allows users to upload files to specific geographic locations and discover/download files within their proximity.

## Architecture

This project uses a serverless architecture with the following AWS services:

- **AWS Lambda** for serverless compute
- **Amazon API Gateway** for REST API endpoints
- **Amazon DynamoDB** for metadata storage
- **Amazon S3** for file storage
- **AWS CloudWatch Events** for scheduled cleanup

## Features

- Upload files with geographic coordinates
- Discover files within proximity (default 100m radius)
- Download files when within range of their location
- User authentication via device ID
- Automatic file expiration and cleanup
- Presigned URLs for direct file upload/download

## Prerequisites

- [Node.js](https://nodejs.org/) v20.x or later
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- [Serverless Framework](https://www.serverless.com/) v4.x or later
- An AWS account with appropriate permissions

## Installation

### Local Development Setup

1. Clone the repository:
   ```
   git clone <repository-url>
   cd locationbasedfileshare/backend
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Run linting:
   ```
   npm run lint
   ```

4. Run tests:
   ```
   npm test
   ```

### Local Development with Serverless Offline

Run the API locally using the Serverless Offline plugin:

```bash
npm run local
```

This will start a local server that emulates API Gateway and Lambda, allowing you to test your functions locally.

### AWS Deployment

For deployment to AWS:

```bash
# Deploy to development stage
npm run deploy

# Deploy to production stage
npm run deploy:prod
```

To remove all resources from AWS:

```bash
npm run remove
```

### Environment Variables Configuration

The following environment variables are defined in the `serverless.yml` file:

| Variable | Description | Default |
|----------|-------------|---------|
| `FILE_RETENTION_DAYS` | Number of days before files expire | 30 |
| `MAX_FILE_SIZE_BYTES` | Maximum file size in bytes | 5242880 (5MB) |
| `DEFAULT_RADIUS_METERS` | Default search radius in meters | 100 |
| `FILES_TABLE` | DynamoDB table for file metadata | auto-generated based on service and stage |
| `FILES_BUCKET` | S3 bucket for file storage | auto-generated based on service and stage |

You can modify these variables in the `serverless.yml` file or override them during deployment.

## API Usage

### Authentication

Before using the API, clients must authenticate:

```bash
curl -X POST https://your-api-endpoint/dev/users/authenticate \
  -H "Content-Type: application/json" \
  -d '{"deviceId": "unique-device-identifier"}'
```

This returns a JWT token:
```json
{
  "token": "eyJhbG...",
  "expiresAt": "2023-04-05T12:00:00Z"
}
```

Use this token in subsequent requests:
```bash
curl -H "Authorization: Bearer eyJhbG..." https://your-api-endpoint/dev/files
```

### Uploading Files

1. Request a presigned URL:
   ```bash
   curl -X POST https://your-api-endpoint/dev/files \
     -H "Authorization: Bearer eyJhbG..." \
     -H "Content-Type: application/json" \
     -d '{
       "name": "Sample File",
       "description": "This is a sample file",
       "latitude": 40.7128,
       "longitude": -74.0060,
       "contentType": "image/jpeg",
       "fileSize": 102400,
       "retentionHours": 720
     }'
   ```

2. Use the returned URL to upload the file directly to S3:
   ```bash
   curl -X PUT "https://presigned-url" \
     -H "Content-Type: image/jpeg" \
     --data-binary @/path/to/local/file.jpg
   ```

### Finding Nearby Files

```bash
curl -X GET "https://your-api-endpoint/dev/files?latitude=40.7128&longitude=-74.0060&radius=200" \
  -H "Authorization: Bearer eyJhbG..."
```

### Downloading Files

1. Get a download URL:
   ```bash
   curl -X GET "https://your-api-endpoint/dev/files/file-id/download?latitude=40.7128&longitude=-74.0060" \
     -H "Authorization: Bearer eyJhbG..."
   ```

2. Use the returned URL to download the file:
   ```bash
   curl "https://presigned-download-url" -o downloaded-file.jpg
   ```

## Monitoring and Debugging

### CloudWatch Logs

Each Lambda function logs to CloudWatch Logs. To view logs using the Serverless Framework:

```bash
# View logs for a specific function
serverless logs -f getNearbyFiles

# Stream logs in real-time
serverless logs -f getNearbyFiles -t
```

### Troubleshooting

If you encounter issues:

1. Verify AWS credentials are correctly configured
2. Check CloudWatch logs for detailed error messages
3. Ensure IAM roles have proper permissions
4. For local testing, verify Serverless Offline is correctly installed and configured

## Security Considerations

- All endpoints (except authentication) require valid JWT tokens
- Files can only be downloaded when the user is within proximity of the file's location
- S3 bucket permissions are restricted to necessary operations
- Files automatically expire after the configured retention period
- No sensitive information is stored in plaintext

## Development

### Project Structure

```
.
├── src/
│   ├── handlers/            # Lambda function handlers
│   ├── middleware/          # Middleware components
│   ├── models/              # Data models
│   └── utils/               # Utility functions
├── tests/
│   ├── unit/                # Unit tests
│   └── integration/         # Integration tests
├── serverless.yml           # Serverless Framework configuration
└── swagger.json             # API specification
```

### Key Dependencies

| Dependency | Version | Purpose |
|------------|---------|---------|
| AWS SDK v3 | ^3.540.0 | AWS services integration |
| Serverless Framework | ^4.7.0 | Deployment management |
| Node.js | 20.x | Runtime |
| Jest | ^29.7.0 | Testing |
| Geolib | ^3.3.4 | Geospatial operations |
| Joi | ^17.13.3 | Validation |
| UUID | ^11.1.0 | ID generation |

### Adding New Features

1. Define the function and API endpoint in `serverless.yml`
2. Implement the handler in `src/handlers/`
3. Add utility functions as needed
4. Write tests

## Flutter Frontend Integration

### API Endpoint Configuration

The backend provides a fixed API endpoint URL for the Flutter frontend app to use:

1. **Default Configuration**: The Serverless Framework automatically sets the `API_BASE_URL` environment variable to the deployed API Gateway endpoint URL.

2. **Custom Domain**: For production environments, you can configure a custom domain in `serverless.yml`.

3. **In Flutter App**: Use the following code to access the backend API:

   ```dart
   // api_service.dart
   class ApiService {
     // Use this fixed API endpoint URL in your Flutter app
     static const String baseUrl = 'https://api.geofyle.com/prod';
     // For development, you can override this with your deployed endpoint
     // static const String baseUrl = 'https://your-api-id.execute-api.region.amazonaws.com/dev';
     
     // API methods go here...
   }
   ```

4. **Environment-specific Configuration**: For different environments, you can use Flutter's environment configurations:

   ```dart
   // config.dart
   class Config {
     static const String apiBaseUrl = String.fromEnvironment(
       'API_BASE_URL',
       defaultValue: 'https://api.geofyle.com/prod',
     );
   }
   ```

## License

This project is licensed under the ISC License.