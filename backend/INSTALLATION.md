# Installation Guide for Location-Based File Share Backend

This document provides step-by-step instructions for setting up and deploying the Location-Based File Share Backend on AWS using the Serverless Framework.

## Prerequisites

Before you begin, ensure you have the following installed and configured:

1. **Node.js and npm**
   ```bash
   # Check if installed
   node --version  # Should be v20.x or later
   npm --version
   
   # Install if needed (example for Ubuntu)
   curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```

2. **AWS CLI**
   ```bash
   # Check if installed
   aws --version
   
   # Install if needed
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   
   # Configure with your AWS credentials
   aws configure
   ```

3. **Serverless Framework**
   ```bash
   # Check if installed
   serverless --version  # or sls --version
   
   # Install if needed
   npm install -g serverless
   ```

## Local Development Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd locationbasedfileshare/backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Run the local development server**
   ```bash
   npm run local
   
   # or directly
   scripts/local.sh
   ```
   This will start the API on http://localhost:3000/

4. **Run tests**
   ```bash
   # Run all tests
   npm test
   
   # Run only unit tests
   npm run test:unit
   
   # Run only integration tests
   npm run test:integration
   ```

## Deployment to AWS

### Option 1: Using the Deployment Script (Recommended)

The deployment script provides an interactive way to configure and deploy the application:

```bash
# Make sure the script is executable
chmod +x scripts/deploy.sh

# Run the deployment script
npm run deploy

# or directly
scripts/deploy.sh
```

Follow the prompts to configure your deployment:
- Stage name (default: dev)
- AWS region
- Configuration parameters like file retention period

### Option 2: Manual Deployment with Serverless Framework Commands

If you prefer to have more control over each step:

```bash
# Deploy to development stage
serverless deploy --stage dev --region us-east-1

# Deploy to production stage
serverless deploy --stage prod --region us-east-1
```

You can also pass additional parameters:

```bash
serverless deploy --stage dev --region us-east-1 --param="FILE_RETENTION_DAYS=60" --param="MAX_FILE_SIZE_BYTES=10485760"
```

### Viewing Deployment Information

After deployment, you can view information about your deployed service:

```bash
serverless info --stage dev
```

This will show details such as your API endpoint URLs, Lambda functions, and other resources.

## Cleaning Up Resources

When you no longer need the application, you can delete all AWS resources:

```bash
# Using npm script
npm run remove

# Or directly with Serverless CLI
serverless remove --stage dev
```

## Troubleshooting

### Deployment Issues

1. **CredentialsError: Missing credentials in config**
   - Run `aws configure` to set up your AWS credentials

2. **Permission denied errors**
   - Check your IAM user has the necessary permissions
   - Minimum permissions required: CloudFormation, S3, IAM, Lambda, API Gateway, DynamoDB

3. **S3 bucket already exists**
   - The Serverless Framework attempts to create an S3 bucket with a name based on your service and stage
   - If there's a conflict, you may need to modify the bucket name in `serverless.yml`

### Local Development Issues

1. **Port already in use**
   - Change the port in the `custom.serverless-offline.httpPort` setting in `serverless.yml`

2. **Missing dependencies**
   - Run `npm install` to ensure all dependencies are installed

3. **Serverless Offline errors**
   - Make sure `serverless-offline` plugin is correctly installed and configured
   - Check if there are compatibility issues with your Node.js version

### API Testing Issues

1. **Authentication errors**
   - Ensure you're using a valid JWT token
   - The token expires after 24 hours by default

2. **Connection timeout**
   - Check network connectivity
   - Verify API endpoint URL is correct

## Security Best Practices

1. **JWT Secret**
   - In production, use AWS Secrets Manager or Parameter Store to manage secrets
   - Update the `serverless.yml` file to reference the secret

2. **IAM Permissions**
   - Follow the principle of least privilege when setting up IAM roles
   - Review and restrict permissions in `serverless.yml`

3. **API Gateway**
   - Consider adding rate limiting to prevent abuse
   - In production, set up a custom domain with HTTPS

4. **S3 Bucket**
   - Ensure buckets are not publicly accessible
   - Enable server-side encryption for stored files

## Advanced Configuration

### Custom Domains

For production environments, you may want to set up a custom domain for your API:

1. **Install the domain plugin**
   ```bash
   npm install --save-dev serverless-domain-manager
   ```

2. **Add to your serverless.yml**
   ```yaml
   plugins:
     - serverless-offline
     - serverless-domain-manager
   
   custom:
     customDomain:
       domainName: api.yourdomain.com
       certificateName: '*.yourdomain.com'
       basePath: ''
       stage: ${self:provider.stage}
       createRoute53Record: true
   ```

3. **Create the domain**
   ```bash
   serverless create_domain
   ```

4. **Deploy your service**
   ```bash
   serverless deploy
   ```

### Environment Variables

You can use a `.env` file for local development and environment-specific variables during deployment:

1. **Create a .env file for local development**
   ```
   FILES_TABLE=local-files-table
   FILES_BUCKET=local-files-bucket
   MAX_FILE_SIZE_BYTES=5242880
   DEFAULT_RADIUS_METERS=100
   FILE_RETENTION_DAYS=30
   JWT_SECRET=local-dev-secret
   ```

2. **For different deployment stages, create stage-specific .env files**
   ```
   # .env.prod
   FILE_RETENTION_DAYS=60
   MAX_FILE_SIZE_BYTES=10485760
   ```

3. **Use with deployment**
   ```bash
   serverless deploy --stage prod --env .env.prod
   ```

## Project Dependencies

This project uses the following major dependencies:

| Dependency | Version | Purpose |
|------------|---------|---------|
| AWS SDK v3 | ^3.540.0 | AWS services integration |
| Serverless Framework | ^4.7.0 | Deployment and infrastructure management |
| Node.js | 20.x | Runtime environment |
| Jest | ^29.7.0 | Testing framework |
| Geolib | ^3.3.4 | Geospatial calculations |
| Joi | ^17.13.3 | Data validation |
| UUID | ^11.1.0 | Unique identifier generation |