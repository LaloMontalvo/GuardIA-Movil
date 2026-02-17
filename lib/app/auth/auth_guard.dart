import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'session_service.dart';

/// ChangeNotifier que escucha FirebaseAuth.authStateChanges()
/// y actúa como `refreshListenable` del GoRouter.
///
/// Cuando el estado de auth cambia, notifica al router para
/// que re-evalúe el `redirect`.
class AuthGuard extends ChangeNotifier {
  final SessionService _sessionService;
  late final StreamSubscription<fb.User?> _subscription;

  bool _isLoggedIn = false;
  bool _isProfileValid = false;
  bool _initialCheckDone = false;

  AuthGuard(this._sessionService) {
    // Estado inicial
    _isLoggedIn = _sessionService.isLoggedIn;
    _isProfileValid = _sessionService.isProfileValid;

    // Escuchar cambios de auth
    _subscription = _sessionService.authStateChanges.listen(_onAuthStateChanged);
  }

  bool get isLoggedIn => _isLoggedIn;
  bool get isProfileValid => _isProfileValid;
  bool get initialCheckDone => _initialCheckDone;
  String? get redirectReason => _sessionService.redirectReason;

  /// Limpia el motivo de redirección (para no mostrarlo múltiples veces).
  void clearRedirectReason() => _sessionService.clearRedirectReason();

  /// Marca la validación inicial como completada (llamado desde Splash).
  void markInitialCheckDone() {
    _initialCheckDone = true;
    _syncFromService();
    notifyListeners();
  }

  /// Valida el perfil Firestore y actualiza flags.
  /// Se llama desde el Splash al inicio y después del login.
  Future<void> validateProfile() async {
    try {
      await _sessionService.validateProfileOrSignOut();
      _isProfileValid = true;
    } catch (e) {
      _isProfileValid = false;
    }
    _syncFromService();
    notifyListeners();
  }

  /// Cierra sesión.
  Future<void> signOut() async {
    await _sessionService.signOut();
    _isLoggedIn = false;
    _isProfileValid = false;
    notifyListeners();
  }

  void _onAuthStateChanged(fb.User? user) {
    final wasLoggedIn = _isLoggedIn;
    _isLoggedIn = user != null;

    if (!_isLoggedIn) {
      _isProfileValid = false;
    }

    // Solo notificar si hubo cambio real
    if (wasLoggedIn != _isLoggedIn) {
      _syncFromService();
      notifyListeners();
    }
  }

  void _syncFromService() {
    _isLoggedIn = _sessionService.isLoggedIn;
    _isProfileValid = _sessionService.isProfileValid;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
