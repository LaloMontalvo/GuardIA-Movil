import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../domain/entities/role.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/errors/exceptions.dart';

/// Implementación de AuthRepository usando Firebase Authentication
class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth;
  final SecureStorageService _storageService;

  FirebaseAuthRepository(this._storageService)
      : _firebaseAuth = fb.FirebaseAuth.instance;

  @override
  Future<User> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw UnauthorizedException('No se pudo obtener el usuario');
      }

      final user = _mapFirebaseUser(firebaseUser);

      // Guardar datos localmente para persistir sesión
      await _storageService.saveAccessToken(await firebaseUser.getIdToken() ?? '');
      await _storageService.saveRefreshToken(firebaseUser.refreshToken ?? '');
      await _storageService.saveUserData(jsonEncode({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'role': 'user',
      }));

      return user;
    } on fb.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw UnauthorizedException('No existe una cuenta con este correo');
        case 'wrong-password':
          throw UnauthorizedException('Contraseña incorrecta');
        case 'invalid-email':
          throw UnauthorizedException('Correo electrónico inválido');
        case 'user-disabled':
          throw UnauthorizedException('Esta cuenta ha sido deshabilitada');
        case 'invalid-credential':
          throw UnauthorizedException('Credenciales inválidas');
        default:
          throw UnauthorizedException('Error de autenticación: ${e.message}');
      }
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException('Error inesperado al iniciar sesión');
    }
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw ServerException('No se pudo crear el usuario');
      }

      // Actualizar el displayName
      await firebaseUser.updateDisplayName(name);
      await firebaseUser.reload();

      final user = _mapFirebaseUser(_firebaseAuth.currentUser ?? firebaseUser);

      await _storageService.saveAccessToken(await firebaseUser.getIdToken() ?? '');
      await _storageService.saveRefreshToken(firebaseUser.refreshToken ?? '');
      await _storageService.saveUserData(jsonEncode({
        'id': user.id,
        'name': name,
        'email': user.email,
        'role': 'user',
      }));

      return user.copyWith(name: name);
    } on fb.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw ServerException('Ya existe una cuenta con este correo');
        case 'weak-password':
          throw ServerException('La contraseña es muy débil');
        default:
          throw ServerException('Error al registrar: ${e.message}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error inesperado al registrar');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      return _mapFirebaseUser(firebaseUser);
    }

    // Fallback: leer de almacenamiento local
    try {
      final userDataString = await _storageService.getUserData();
      if (userDataString == null) return null;

      final userData = jsonDecode(userDataString) as Map<String, dynamic>;
      return User(
        id: userData['id'] as String,
        name: userData['name'] as String,
        email: userData['email'] as String,
        role: Role.fromString(userData['role'] as String),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> refreshAccessToken() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      throw UnauthorizedException('No hay sesión activa');
    }

    final newToken = await firebaseUser.getIdToken(true);
    if (newToken != null) {
      await _storageService.saveAccessToken(newToken);
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _storageService.deleteAll();
  }

  @override
  Future<bool> hasActiveSession() async {
    // Primero verificar Firebase
    if (_firebaseAuth.currentUser != null) return true;
    // Fallback a tokens locales
    return await _storageService.hasTokens();
  }

  /// Mapea un FirebaseUser a nuestra entidad User
  User _mapFirebaseUser(fb.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'Usuario',
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
      role: Role.user,
    );
  }
}
