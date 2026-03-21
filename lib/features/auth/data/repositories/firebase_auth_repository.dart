import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';

/// Implementación de AuthRepository usando Firebase Authentication
class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth;
  final SecureStorageService _storageService;
  final DioClient _dioClient;

  FirebaseAuthRepository(this._storageService, this._dioClient)
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

      // Guardar access token temporalmente para que Dio pueda usarlo al traer el perfil
      await _storageService.saveAccessToken(await firebaseUser.getIdToken() ?? '');

      final user = await _mapFirebaseUser(firebaseUser);

      // Guardar el resto de datos localmente para persistir sesión
      await _storageService.saveRefreshToken(firebaseUser.refreshToken ?? '');
      await _storageService.saveUserData(jsonEncode({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'role': user.role.name,
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

      // Guardar access token para que Dio lo pueda usar
      await _storageService.saveAccessToken(await firebaseUser.getIdToken() ?? '');

      final user = await _mapFirebaseUser(_firebaseAuth.currentUser ?? firebaseUser);

      await _storageService.saveRefreshToken(firebaseUser.refreshToken ?? '');
      await _storageService.saveRefreshToken(firebaseUser.refreshToken ?? '');
      await _storageService.saveUserData(jsonEncode({
        'id': user.id,
        'name': name,
        'email': user.email,
        'role': user.role.name,
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
      return await _mapFirebaseUser(firebaseUser);
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

  /// Mapea un FirebaseUser a nuestra entidad User recuperando datos de la API PostgreSQL
  Future<User> _mapFirebaseUser(fb.User firebaseUser) async {
    String roleString = 'operator'; // Valor por defecto
    String name = firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'Usuario';

    try {
      final response = await _dioClient.get('${ApiConstants.baseUrl}/users/${firebaseUser.uid}');
      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data['item'] as Map<String, dynamic>;
        
        if (userData.containsKey('role')) {
          roleString = userData['role'].toString().toLowerCase();
        }
        
        if (userData.containsKey('fullName')) {
          name = userData['fullName'].toString();
        }
      }
    } catch (e) {
      // Ignorar, fallback a default y firebase display name
    }

    // Normalizar role a ingles si viene del server en espanol
    if (roleString == 'administrador' || roleString == 'admin') {
      roleString = 'admin';
    } else if (roleString == 'operador') {
      roleString = 'operator';
    }

    return User(
      id: firebaseUser.uid,
      name: name,
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
      role: Role.fromString(roleString),
    );
  }
}
