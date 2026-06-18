import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Servicio para almacenamiento seguro de datos sensibles (tokens, credenciales)
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  // ========== Access Token ==========

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }

  // ========== Refresh Token ==========

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  // ========== User Data ==========

  Future<void> saveUserData(String userData) async {
    await _storage.write(key: AppConstants.userDataKey, value: userData);
  }

  Future<String?> getUserData() async {
    return await _storage.read(key: AppConstants.userDataKey);
  }

  // ========== 2FA State ==========

  Future<void> save2faVerified(bool isVerified) async {
    await _storage.write(key: '2fa_verified', value: isVerified.toString());
  }

  Future<bool> get2faVerified() async {
    final value = await _storage.read(key: '2fa_verified');
    return value == 'true';
  }

  // ========== Utilities ==========

  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  Future<void> deleteTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
    await _storage.delete(key: '2fa_verified');
  }
}
