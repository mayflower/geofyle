# GeoFyle (Frontend)

A Flutter mobile application that allows users to share and discover files based on geographic proximity. Files are only accessible to other users who are physically located within 100 meters of where the file was originally uploaded.

## Author

This application was written by Johann-Peter Hartmann (johann-peter.hartmann@mayflower.de) as a demo case for Claude Code usage.

## Features

- **Geo-Based File Discovery**: View files that have been uploaded within 100 meters of your current location
- **Interactive Map View**: Visual representation of available files on a map interface
- **List View**: Alternative method to browse nearby files in a list format
- **File Upload**: Upload files with custom descriptions and retention periods
- **File Download**: Download files when physically present at the file's location
- **Permissions Management**: Proper handling of location permissions
- **Animated UI Elements**: Smooth transitions and loading animations using Lottie

## Architecture

This app follows a clean architecture approach with:

- **Models**: Data structures (e.g., FileItem)
- **Providers**: State management using the Provider pattern
- **Services**: Backend API communication and device capabilities
- **Screens**: User interface components
- **Widgets**: Reusable UI elements
- **Animations**: Custom animations and transitions
- **Utils**: Helper functions and configurations

## Technical Stack

- **Framework**: Flutter (SDK ^3.7.0)
- **State Management**: Provider
- **Location Services**: Geolocator
- **Mapping**: Flutter Map with Latlong2
- **Animations**: Lottie
- **File Handling**: File Picker, Path Provider
- **API Communication**: HTTP
- **Permissions**: Permission Handler

## Getting Started

### Prerequisites

- Flutter SDK ^3.7.0
- Dart SDK
- Android Studio / Xcode for device emulation

### Installation

1. Clone the repository
   ```
   git clone https://github.com/yourusername/geofyle.git
   cd geofyle/frontend
   ```

2. Install dependencies
   ```
   flutter pub get
   ```

3. Run the app
   ```
   flutter run
   ```

### Building for Production

#### Android
```
flutter build apk
```

#### iOS
```
flutter build ios
```

## Development

### Key Commands

- **Run app**: `flutter run`
- **Test all**: `flutter test`
- **Test single file**: `flutter test test/path_to_test.dart`
- **Lint code**: `flutter analyze`
- **Format code**: `dart format lib`
- **Update dependencies**: `flutter pub get`

### Project Structure

```
lib/
├── animations/       # Custom animations and transitions
├── models/           # Data models
├── providers/        # State management
├── screens/          # App screens
├── services/         # API and device services
├── utils/            # Helper functions and configurations
├── widgets/          # Reusable UI components
└── main.dart         # App entry point
```

## Dependencies

- **cupertino_icons**: ^1.0.8
- **lottie**: ^3.3.1
- **geolocator**: ^13.0.2
- **flutter_map**: ^8.1.0
- **latlong2**: ^0.9.1
- **permission_handler**: ^11.4.0
- **provider**: ^6.1.2
- **path_provider**: ^2.1.5
- **file_picker**: ^9.0.2
- **http**: ^1.3.0
- **intl**: ^0.20.2

## License

MIT License

Copyright (c) 2025 Johann-Peter Hartmann

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Contact

Johann-Peter Hartmann (johann-peter.hartmann@mayflower.de)