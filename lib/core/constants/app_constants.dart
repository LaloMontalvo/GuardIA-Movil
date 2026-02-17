class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'GuardIA';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String onlyWifiKey = 'only_wifi';
  static const String notificationsEnabledKey = 'notifications_enabled';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Mock API
  static const bool useMockApi = true; // Cambiar a false cuando haya backend real
  static const int mockDelayMs = 800;

  // Camera
  static const int maxCameraNameLength = 50;

  // Alert
  static const int maxAlertNoteLength = 500;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
}
