import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../../../core/di/providers.dart';
import '../../../../app/auth/session_service.dart';
import '../../../../app/auth/auth_guard.dart';

// ========== Session Service (anti-spoofing) ==========

final sessionServiceProvider = Provider<SessionService>((ref) {
  return SessionService(storageService: ref.watch(secureStorageServiceProvider));
});

// ========== Auth Guard (router refreshListenable) ==========

final authGuardProvider = Provider<AuthGuard>((ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  return AuthGuard(sessionService);
});

// ========== Repository Provider ==========

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(
    ref.watch(secureStorageServiceProvider),
    ref.watch(dioClientProvider),
  );
});

// ========== Auth State Provider ==========

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(sessionServiceProvider),
    ref.watch(authGuardProvider),
  );
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final SessionService _sessionService;
  final AuthGuard _authGuard;

  AuthNotifier(
    this._authRepository,
    this._sessionService,
    this._authGuard,
  ) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final hasSession = await _authRepository.hasActiveSession();
      
      if (hasSession) {
        final user = await _authRepository.getCurrentUser();
        state = state.copyWith(user: user);
      }
    } catch (e) {
      // Ignorar errores en verificación inicial
    }
  }

  /// Login con validación Firestore anti-spoofing.
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. Autenticar con Firebase
      await _sessionService.signIn(email, password);

      // 2. Obtener datos del usuario para el estado local
      final user = await _authRepository.getCurrentUser();
      state = AuthState(user: user, isLoading: false);

      // 3. Validar perfil y publicarlo en el guard
      await _authGuard.validateProfile();
      _authGuard.markInitialCheckDone();
    } catch (e) {
      state = AuthState(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authRepository.register(
        name: name,
        email: email,
        password: password,
      );
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      state = AuthState(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    await _sessionService.signOut();
    await _authRepository.logout();
    state = const AuthState();
  }
}
