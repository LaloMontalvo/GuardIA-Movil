import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        // Intentar renovar token usando Firebase directamente
        final currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          // Forzar la obtención de un nuevo token de Firebase
          final newAccessToken = await currentUser.getIdToken(true);

          if (newAccessToken != null) {
            // Guardar el nuevo token
            await _storageService.saveAccessToken(newAccessToken);

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
        // Si falla el refresh, limpiar tokens y sesión
        await _storageService.deleteTokens();
        await FirebaseAuth.instance.signOut();
      }
    }

    handler.next(err);
  }
}
