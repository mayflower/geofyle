# GeoFyle - Location-Based File Sharing

GeoFyle is a mobile application that enables users to share and discover files based on geographic proximity. Files are only accessible to users who are physically located within 100 meters of where the file was originally uploaded.

## Project Overview

The project consists of two main components:

1. **[Backend](/backend)**: A serverless AWS backend using Lambda, API Gateway, DynamoDB, and S3
2. **[Frontend](/frontend)**: A Flutter mobile application for iOS and Android

## Key Features

- Upload files with geographic coordinates
- Discover files within proximity (default 100m radius)
- Interactive map view of nearby files
- File download only when physically at the file's location
- User authentication via device ID
- Automatic file expiration and cleanup

## Architecture

### Backend Architecture

The serverless backend utilizes:
- AWS Lambda for compute
- Amazon API Gateway for REST endpoints
- Amazon DynamoDB for metadata storage
- Amazon S3 for file storage
- AWS CloudWatch Events for scheduled cleanup

### Frontend Architecture

The Flutter app follows a clean architecture with:
- Provider-based state management
- Geolocator for precise location tracking
- Flutter Map for interactive mapping
- Lottie for smooth animations
- HTTP for API communication

## Getting Started

For detailed setup and usage instructions, see:
- [Backend Documentation](/backend/README.md)
- [Frontend Documentation](/frontend/README.md)

## Author

This application was written by Johann-Peter Hartmann (johann-peter.hartmann@mayflower.de) as a demo case for Claude Code usage.

## License

This project is licensed under the MIT License.