import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/mock_api_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/errors/exceptions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final MockApiService _mockApiService;
  final SecureStorageService _storageService;

  AuthRepositoryImpl(this._mockApiService, this._storageService);

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await _mockApiService.login(email, password);

      final accessToken = response.data['accessToken'] as String;
      final refreshToken = response.data['refreshToken'] as String;
      final userData = response.data['user'] as Map<String, dynamic>;

      // Guardar tokens y datos de usuario
      await _storageService.saveAccessToken(accessToken);
      await _storageService.saveRefreshToken(refreshToken);
      await _storageService.saveUserData(jsonEncode(userData));

      return _userFromJson(userData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Credenciales inválidas');
      }
      throw ServerException('Error al iniciar sesión');
    } catch (e) {
      throw ServerException('Error inesperado');
    }
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _mockApiService.register({
        'name': name,
        'email': email,
        'password': password,
      });

      final accessToken = response.data['accessToken'] as String;
      final refreshToken = response.data['refreshToken'] as String;
      final userData = response.data['user'] as Map<String, dynamic>;

      await _storageService.saveAccessToken(accessToken);
      await _storageService.saveRefreshToken(refreshToken);
      await _storageService.saveUserData(jsonEncode(userData));

      return _userFromJson(userData);
    } catch (e) {
      throw ServerException('Error al registrar usuario');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userDataString = await _storageService.getUserData();
      
      if (userDataString == null) return null;

      final userData = jsonDecode(userDataString) as Map<String, dynamic>;
      return _userFromJson(userData);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> refreshAccessToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      
      if (refreshToken == null) {
        throw UnauthorizedException('No refresh token');
      }

      final response = await _mockApiService.refreshToken(refreshToken);

      final newAccessToken = response.data['accessToken'] as String;
      final newRefreshToken = response.data['refreshToken'] as String;

      await _storageService.saveAccessToken(newAccessToken);
      await _storageService.saveRefreshToken(newRefreshToken);
    } catch (e) {
      throw UnauthorizedException('Error al renovar token');
    }
  }

  @override
  Future<void> logout() async {
    await _storageService.deleteAll();
  }

  @override
  Future<bool> hasActiveSession() async {
    return await _storageService.hasTokens();
  }

  // Helper para convertir JSON a User
  User _userFromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: Role.fromString(json['role'] as String),
    );
  }
}
