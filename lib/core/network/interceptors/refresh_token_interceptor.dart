import 'package:dio/dio.dart';
import '../../storage/secure_storage_service.dart';
import '../../constants/api_constants.dart';

/// Interceptor que detecta 401 y renueva el token automáticamente
class RefreshTokenInterceptor extends Interceptor {
  final SecureStorageService _storageService;
  final Dio _dio;

  RefreshTokenInterceptor(this._storageService, this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Si es 401 (no autorizado)
    if (err.response?.statusCode == 401) {
      try {
        // Intentar renovar token
        final refreshToken = await _storageService.getRefreshToken();

        if (refreshToken != null && refreshToken.isNotEmpty) {
          // Llamar al endpoint de refresh
          final response = await _dio.post(
            ApiConstants.refreshToken,
            data: {'refreshToken': refreshToken},
            options: Options(
              headers: {
                // No enviar el access token expirado
                ApiConstants.authHeader: null,
              },
            ),
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['accessToken'];
            final newRefreshToken = response.data['refreshToken'];

            // Guardar nuevos tokens
            await _storageService.saveAccessToken(newAccessToken);
            await _storageService.saveRefreshToken(newRefreshToken);

            // Reintentar el request original con el nuevo token
            final originalRequest = err.requestOptions;
            originalRequest.headers[ApiConstants.authHeader] =
                'Bearer $newAccessToken';

            final retryResponse = await _dio.request(
              originalRequest.path,
              options: Options(
                method: originalRequest.method,
                headers: originalRequest.headers,
              ),
              data: originalRequest.data,
              queryParameters: originalRequest.queryParameters,
            );

            return handler.resolve(retryResponse);
          }
        }
      } catch (e) {
        // Si falla el refresh, limpiar tokens y dejar que el error continúe
        await _storageService.deleteTokens();
      }
    }

    handler.next(err);
  }
}
