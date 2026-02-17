import 'package:dio/dio.dart';
import '../../storage/secure_storage_service.dart';
import '../../constants/api_constants.dart';

/// Interceptor que inyecta el access token en cada request
class AuthInterceptor extends Interceptor {
  final SecureStorageService _storageService;

  AuthInterceptor(this._storageService);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Obtener el access token
    final accessToken = await _storageService.getAccessToken();

    // Si existe, agregarlo al header
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers[ApiConstants.authHeader] = 'Bearer $accessToken';
    }

    handler.next(options);
  }
}
