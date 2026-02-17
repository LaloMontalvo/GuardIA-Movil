import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  
  return DioClient(
    baseUrl: ApiConstants.baseUrl,
    authInterceptor: AuthInterceptor(storage),
    refreshTokenInterceptor: RefreshTokenInterceptor(
      storage,
      // Se pasa una instancia básica de Dio para evitar dependencia circular
      ref.watch(mockApiServiceProvider) as dynamic,
    ),
  );
});
