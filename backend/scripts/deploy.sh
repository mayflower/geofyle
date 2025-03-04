#!/bin/bash
set -e

# Get directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Location-Based File Share Backend Deployment ==="
echo "This script will deploy the application to AWS using Serverless Framework."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed. Please install it first."
    echo "Visit: https://aws.amazon.com/cli/"
    exit 1
fi

# Check if Serverless Framework is installed
if ! command -v serverless &> /dev/null && ! command -v sls &> /dev/null; then
    echo "Error: Serverless Framework is not installed. Please install it first."
    echo "Run: npm install -g serverless"
    exit 1
fi

# Prompt for configuration values
read -p "Enter stage name [dev]: " STAGE_NAME
STAGE_NAME=${STAGE_NAME:-dev}

read -p "Enter AWS region [us-east-1]: " AWS_REGION
AWS_REGION=${AWS_REGION:-us-east-1}

read -p "Enter file retention days [30]: " FILE_RETENTION_DAYS
FILE_RETENTION_DAYS=${FILE_RETENTION_DAYS:-30}

read -p "Enter max file size in bytes [5242880]: " MAX_FILE_SIZE_BYTES
MAX_FILE_SIZE_BYTES=${MAX_FILE_SIZE_BYTES:-5242880}

read -p "Enter default search radius in meters [100]: " DEFAULT_RADIUS_METERS
DEFAULT_RADIUS_METERS=${DEFAULT_RADIUS_METERS:-100}

# Confirm settings
echo
echo "Deployment settings:"
echo "  Stage: $STAGE_NAME"
echo "  AWS Region: $AWS_REGION"
echo "  File Retention Days: $FILE_RETENTION_DAYS"
echo "  Max File Size: $MAX_FILE_SIZE_BYTES bytes"
echo "  Default Search Radius: $DEFAULT_RADIUS_METERS meters"
echo

read -p "Proceed with deployment? (y/n) " CONFIRM
if [[ $CONFIRM != "y" && $CONFIRM != "Y" ]]; then
    echo "Deployment cancelled."
    exit 0
fi

# Navigate to project directory
cd "$PROJECT_DIR"

# Deploy with Serverless Framework
echo "Deploying application with Serverless Framework..."
npx serverless deploy \
    --stage $STAGE_NAME \
    --region $AWS_REGION \
    --verbose

# Get the API endpoint URL
API_ENDPOINT=$(npx serverless info --stage $STAGE_NAME --verbose | grep -o 'https://[^[:space:]]*')

echo
echo "Deployment complete!"
echo "API Endpoint: $API_ENDPOINT"
echo
echo "To test the API, try:"
echo "curl -X POST $API_ENDPOINT/users/authenticate -H \"Content-Type: application/json\" -d '{\"deviceId\":\"test-device\"}'"