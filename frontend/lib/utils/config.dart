class AppConfig {
  // API endpoints
  static const String apiBaseUrl = 'https://api.geofyle.com';
  
  // Location settings
  static const double defaultSearchRadius = 100.0; // meters
  
  // File settings
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  
  // Timeout durations
  static const int apiTimeoutSeconds = 30;
}