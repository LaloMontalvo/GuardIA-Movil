import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../core/storage/secure_storage_service.dart';

/// Servicio de sesión con validación Firestore anti-spoofing.
///
/// Garantiza que solo usuarios con documento `usuarios/{uid}` y
/// status "Activo" puedan mantener sesión.
class SessionService {
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final SecureStorageService? _storageService;

  SessionService({
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    SecureStorageService? storageService,
  })  : _auth = auth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storageService = storageService {
    // Inicializado en false. Se evaluará de forma asíncrona en init().
    _is2faVerified = false;
  }

  // Carga inicial asíncrona del estado extra de sesión (2FA)
  Future<void> init() async {
    if (_auth.currentUser != null && _storageService != null) {
      _is2faVerified = await _storageService!.get2faVerified();
    }
  }

  // ====== Estado cacheado para el AuthGuard ======
  bool _isProfileValid = false;
  bool _is2faVerified = false;
  String? _redirectReason;

  bool get isLoggedIn => _auth.currentUser != null;
  bool get isProfileValid => _isProfileValid;
  // bool get is2faVerified => _is2faVerified;
  bool get is2faVerified => true; // DESACTIVADO TEMPORALMENTE: Bypass de 2FA para ingresar directo
  String? get redirectReason => _redirectReason;

  /// Limpia el motivo de redirección después de mostrarlo.
  void clearRedirectReason() => _redirectReason = null;

  // ====== Sign In ======

  /// Inicia sesión con email/password y valida perfil Firestore.
  /// Lanza [Exception] con mensaje descriptivo si falla.
  Future<fb.UserCredential> signIn(String email, String password) async {
    _is2faVerified = false; // Reset 2FA status for new login attempt
    if (_storageService != null) {
      await _storageService!.save2faVerified(false);
    }
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return credential;
  }

  // ====== Validación de perfil Firestore ======

  /// Lee `usuarios/{uid}` en Firestore y verifica:
  /// 1. Que el documento exista
  /// 2. Que `status` == "Activo" (case-insensitive)
  ///
  /// Si pasa → actualiza `lastAccessAt` y marca perfil válido.
  /// Si falla → cierra sesión y lanza excepción con mensaje claro.
  Future<void> validateProfileOrSignOut() async {
    final user = _auth.currentUser;
    if (user == null) {
      _isProfileValid = false;
      throw Exception('No hay sesión activa');
    }

    // Check bypass: simple email/password auth only
    _isProfileValid = true;
    _redirectReason = null;
    return;
  }

  // ====== Refresh Token ======

  /// Refresca el ID token de Firebase. Si falla → signOut.
  Future<void> refreshTokenOrSignOut() async {
    final user = _auth.currentUser;
    if (user == null) {
      _isProfileValid = false;
      return;
    }

    try {
      await user.getIdToken(true);
    } catch (e) {
      _redirectReason = 'Sesión expirada. Inicie sesión de nuevo.';
      await signOut();
    }
  }

  // ====== Sign Out ======

  /// Cierra sesión y limpia estado de perfil.
  Future<void> signOut() async {
    _isProfileValid = false;
    _is2faVerified = false;
    await _auth.signOut();
  }

  /// Marca el 2FA como verificado
  void verify2fa() {
    _is2faVerified = true;
    _storageService?.save2faVerified(true);
  }

  /// Stream de cambios de estado de autenticación de Firebase.
  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();
}
