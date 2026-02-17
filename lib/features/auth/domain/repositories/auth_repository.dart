import '../entities/user.dart';

/// Contrato del repositorio de autenticación
abstract class AuthRepository {
  /// Login con email y contraseña
  Future<User> login(String email, String password);

  /// Registro de nuevo usuario
  Future<User> register({
    required String name,
    required String email,
    required String password,
  });

  /// Obtener usuario actual (si hay sesión activa)
  Future<User?> getCurrentUser();

  /// Renovar access token usando refresh token
  Future<void> refreshAccessToken();

  /// Cerrar sesión
  Future<void> logout();

  /// Verificar si hay sesión activa
  Future<bool> hasActiveSession();
}
