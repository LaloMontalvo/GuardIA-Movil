class ApiConstants {
  ApiConstants._();

  // Base URL (producción)
  static const String baseUrl = 'https://guardia-production-d5e6.up.railway.app';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // Endpoints - Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';

  // Endpoints - Cameras
  static const String cameras = '/cameras';
  static String cameraDetail(String id) => '/cameras/$id';
  static String cameraStream(String id) => '/cameras/$id/stream';

  // Endpoints - Alerts
  static const String alerts = '/alerts';
  static String alertDetail(String id) => '/alerts/$id';
  static String updateAlert(String id) => '/alerts/$id';

  // Endpoints - Dashboard
  static const String dashboardStats = '/dashboard/stats';

  // Endpoints - Recordings
  static const String recordings = '/recordings';
  static String recordingDetail(String id) => '/recordings/$id';

  // Endpoints - Panic
  static const String panic = '/panic';

  // Endpoints - User
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';

  // Headers
  static const String authHeader = 'Authorization';
  static const String contentType = 'Content-Type';
  static const String accept = 'Accept';
  static const String applicationJson = 'application/json';
}
