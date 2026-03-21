import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/mock_api_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/interceptors/auth_interceptor.dart';
import '../../../core/network/interceptors/refresh_token_interceptor.dart';
import '../../../core/constants/api_constants.dart';

// ========== Core Services ==========

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final mockApiServiceProvider = Provider<MockApiService>((ref) {
  return MockApiService();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  
  // Instancia básica de Dio para el refresh token interceptor (evita circularidad)
  final basicDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  return DioClient(
    baseUrl: ApiConstants.baseUrl,
    authInterceptor: AuthInterceptor(storage),
    refreshTokenInterceptor: RefreshTokenInterceptor(storage, basicDio),
  );
});
