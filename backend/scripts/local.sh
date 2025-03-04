#!/bin/bash
set -e

# Get directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Location-Based File Share Backend Local Development ==="
echo "This script will start the API locally for development and testing."

# Create a .env file if it doesn't exist
ENV_FILE="$PROJECT_DIR/.env"
if [ ! -f "$ENV_FILE" ]; then
    echo "Creating environment variables file for local development..."
    cat > "$ENV_FILE" << EOF
FILES_TABLE=local-files-table
FILES_BUCKET=local-files-bucket
MAX_FILE_SIZE_BYTES=5242880
DEFAULT_RADIUS_METERS=100
FILE_RETENTION_DAYS=30
JWT_SECRET=local-dev-secret
EOF
    echo "Created $ENV_FILE"
fi

# Navigate to project directory
cd "$PROJECT_DIR"

# Start local API
echo "Starting API locally using Serverless Offline..."
echo "API will be available at: http://localhost:3000/"
echo "Use Ctrl+C to stop the API"
echo

# Start the serverless offline server
npx serverless offline start --stage local

# The script will not reach here unless something goes wrong or the API is stopped with Ctrl+C
echo "API stopped."