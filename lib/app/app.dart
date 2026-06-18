import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'app_router.dart';
import 'theme/app_theme.dart';
import '../core/di/app_providers.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/auth/presentation/providers/auth_providers.dart';

/// App principal de GuardIA
class GuardIAApp extends ConsumerStatefulWidget {
  const GuardIAApp({super.key});

  @override
  ConsumerState<GuardIAApp> createState() => _GuardIAAppState();
}

class _GuardIAAppState extends ConsumerState<GuardIAApp> with WidgetsBindingObserver {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkBiometric();
    }
  }

  Future<void> _checkBiometric() async {
    final isEnabled = ref.read(biometricProvider);
    final authState = ref.read(authStateProvider);
    
    if (isEnabled && authState.user != null && !_isAuthenticating) {
      _isAuthenticating = true;
      final auth = LocalAuthentication();
      final canAuth = await auth.canCheckBiometrics || await auth.isDeviceSupported();
      if (canAuth) {
        bool didAuthenticate = false;
        try {
          didAuthenticate = await auth.authenticate(
            localizedReason: 'Desbloquea GuardIA',
            options: const AuthenticationOptions(stickyAuth: true, biometricOnly: false),
          );
        } catch (e) {
          debugPrint('Error auth: $e');
        }
        
        if (!didAuthenticate) {
          // Si el usuario cancela, cerramos sesión por seguridad
          ref.read(authStateProvider.notifier).logout();
        }
      }
      _isAuthenticating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'GuardIA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
