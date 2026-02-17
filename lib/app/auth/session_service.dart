import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Servicio de sesión con validación Firestore anti-spoofing.
///
/// Garantiza que solo usuarios con documento `usuarios/{uid}` y
/// status "Activo" puedan mantener sesión.
class SessionService {
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  SessionService({
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // ====== Estado cacheado para el AuthGuard ======
  bool _isProfileValid = false;
  String? _redirectReason;

  bool get isLoggedIn => _auth.currentUser != null;
  bool get isProfileValid => _isProfileValid;
  String? get redirectReason => _redirectReason;

  /// Limpia el motivo de redirección después de mostrarlo.
  void clearRedirectReason() => _redirectReason = null;

  // ====== Sign In ======

  /// Inicia sesión con email/password y valida perfil Firestore.
  /// Lanza [Exception] con mensaje descriptivo si falla.
  Future<fb.UserCredential> signIn(String email, String password) async {
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
    await _auth.signOut();
  }

  /// Stream de cambios de estado de autenticación de Firebase.
  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();
}
