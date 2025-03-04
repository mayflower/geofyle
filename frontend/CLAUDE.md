# CLAUDE.md - Flutter GeoFyle App

## Commands
- Run app: `flutter run`
- Test all: `flutter test`
- Test single file: `flutter test test/path_to_test.dart`
- Lint code: `flutter analyze`
- Format code: `dart format lib`
- Build Android: `flutter build apk`
- Build iOS: `flutter build ios`
- Dependencies: `flutter pub get`

## Code Style Guidelines
- **Naming**: Classes use PascalCase, variables/methods use camelCase
- **Privacy**: Prefix private members with underscore (_privateMember)
- **Constants**: Use lowerCamelCase for constants
- **Imports**: Order as dart:*, package:*, relative imports
- **Architecture**: Follow models/, services/, providers/, screens/, widgets/ structure
- **State Management**: Use Provider pattern with ChangeNotifier
- **Error Handling**: Use try/catch with structured error states in providers
- **UI Components**: Prefer const constructors when possible
- **Testing**: Follow AAA pattern (Arrange-Act-Assert) in tests
- **Widget Extraction**: Use widgets to define layout; refactor reusable code into widgets
- **Error Messages**: Generate descriptive error messages with context about why they occurred

## Key Dependencies
- Provider for state management
- Geolocator for location services
- Flutter Map for map visualization
- Lottie for animations