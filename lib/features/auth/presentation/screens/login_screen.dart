import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../providers/auth_providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_alerts.dart';

/// Pantalla de login con header gradiente
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // ====== Throttling anti fuerza bruta ======
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;
  Timer? _lockoutTimer;
  int _lockoutSecondsLeft = 0;

  late AnimationController _animController;
  late Animation<double> _headerFade;
  late Animation<Offset> _formSlide;
  late Animation<double> _formFade;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));
    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
      ),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  /// Verifica si el login está bloqueado por throttling.
  bool get _isLockedOut =>
      _lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!);

  /// Inicia el timer de bloqueo visual.
  void _startLockoutTimer(int seconds) {
    _lockoutSecondsLeft = seconds;
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _lockoutSecondsLeft--;
        if (_lockoutSecondsLeft <= 0) {
          _lockoutUntil = null;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Verificar throttling
    if (_isLockedOut) {
      AppAlerts.showSnackBar(
        context,
        title: 'Cuenta bloqueada temporalmente',
        message: 'Espera $_lockoutSecondsLeft segundos antes de intentar de nuevo',
        type: AlertType.warning,
      );
      return;
    }

    try {
      await ref.read(authStateProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );

      // Login exitoso → reset throttling
      _failedAttempts = 0;
      _lockoutUntil = null;
      _lockoutTimer?.cancel();
      
      // La redirección a '/two-factor' ocurrirá automáticamente a través de GoRouter
      // cuando detecte el cambio de estado de autenticación de Firebase.
    } catch (e) {
      if (mounted) {
        // En caso de que se necesite limpiar un estado de carga general en el futuro
      }
      
      // Incrementar intentos fallidos
      _failedAttempts++;

      // Aplicar bloqueo progresivo
      if (_failedAttempts >= 5) {
        _lockoutUntil = DateTime.now().add(const Duration(seconds: 60));
        _startLockoutTimer(60);
      } else if (_failedAttempts >= 3) {
        _lockoutUntil = DateTime.now().add(const Duration(seconds: 15));
        _startLockoutTimer(15);
      }

      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');

        // Detectar tipo de error para mostrar alerta adecuada
        if (errorMsg.contains('invalid-email')) {
          AppAlerts.showSnackBar(
            context,
            title: 'Correo inválido',
            message: 'El formato del correo electrónico provisto no es válido.',
            type: AlertType.error,
          );
        } else if (errorMsg.contains('no autorizado') || errorMsg.contains('perfil no existe')) {
          // Perfil Firestore no encontrado → Dialog
          AppAlerts.showAlertDialog(
            context,
            title: 'Perfil no encontrado',
            message: 'Tu cuenta de Firebase es válida, pero no tienes un perfil activo en el sistema. Contacta al administrador.',
            type: AlertType.warning,
            confirmText: 'Entendido',
          );
        } else if (errorMsg.contains('user-not-found') || errorMsg.contains('No existe una cuenta')) {
          // Cuenta Firebase no existe → Dialog
          AppAlerts.showAlertDialog(
            context,
            title: 'Cuenta no encontrada',
            message: 'No existe una cuenta registrada con este correo electrónico. Verifica que el correo sea correcto.',
            type: AlertType.error,
            confirmText: 'Reintentar',
          );
        } else if (_isLockedOut) {
          // Bloqueo local por intentos → Warning dialog
          AppAlerts.showAlertDialog(
            context,
            title: 'Demasiados intentos',
            message: 'Has excedido el límite de intentos permitidos. Por seguridad, espera $_lockoutSecondsLeft segundos antes de intentar.',
            type: AlertType.warning,
            confirmText: 'Entendido',
          );
        } else if (errorMsg.contains('wrong-password') || errorMsg.contains('invalid-credential') || errorMsg.contains('Contraseña')) {
          // Contraseña incorrecta → SnackBar premium
          AppAlerts.showSnackBar(
            context,
            title: 'Credenciales incorrectas',
            message: 'La contraseña o el correo ingresados son incorrectos. Verifícalos.',
            type: AlertType.error,
          );
        } else if (errorMsg.contains('user-disabled') || (errorMsg.contains('Cuenta') && errorMsg.contains('Inactiva'))) {
          // Cuenta bloqueada/inactiva de Firebase → Dialog
          AppAlerts.showAlertDialog(
            context,
            title: 'Cuenta suspendida',
            message: 'Esta cuenta ha sido deshabilitada.\n\nContacta al administrador para reactivar tu acceso.',
            type: AlertType.warning,
            confirmText: 'Entendido',
          );
        } else if (errorMsg.contains('network-request-failed') || errorMsg.contains('verificar perfil')) {
          // Error de red/Firestore → SnackBar
          AppAlerts.showSnackBar(
            context,
            title: 'Error de conexión',
            message: 'Ocurrió un error al contactar al servidor. Revisa tu conexión a internet e intenta de nuevo.',
            type: AlertType.warning,
          );
        } else {
          // Error genérico → SnackBar
          AppAlerts.showSnackBar(
            context,
            title: 'Error inesperado',
            message: errorMsg,
            type: AlertType.error,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Gradient header with logo
                FadeTransition(
                  opacity: _headerFade,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 32,
                      bottom: 40,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Logo
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Image.asset('assets/GuardIA.png', width: 60, height: 60),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'GuardIA',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Videovigilancia Inteligente',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Form content
                SlideTransition(
                  position: _formSlide,
                  child: FadeTransition(
                    opacity: _formFade,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Bienvenido de nuevo',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Inicia sesión para continuar',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                            ),
                            const SizedBox(height: 28),

                            // Email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'tu@email.com',
                                prefixIcon: const Icon(Icons.email_outlined),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.accentCyan,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.grey300,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.errorRed,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.errorRed,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingresa tu email';
                                }
                                if (!value.contains('@')) {
                                  return 'Email inválido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                hintText: '••••••••',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.accentCyan,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.grey300,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.errorRed,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.errorRed,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingresa tu contraseña';
                                }
                                if (value.length < 6) {
                                  return 'Mínimo 6 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Login button
                            ElevatedButton(
                              onPressed:
                                  (authState.isLoading || _isLockedOut) ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: _isLockedOut
                                    ? Colors.orange.shade700
                                    : AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: _isLockedOut
                                    ? Colors.orange.shade400
                                    : AppColors.primaryBlue.withOpacity(0.5),
                                disabledForegroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              child: authState.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : _isLockedOut
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.lock_clock, size: 20),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Espera ${_lockoutSecondsLeft}s...',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Text(
                                          'Iniciar Sesión',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                            ),
                            const SizedBox(height: 16),

                            // Links
                            // Forgot password link
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  context.push('/forgot-password');
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.accentCyan,
                                ),
                                child: const Text('¿Olvidaste tu contraseña?',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ),


                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      // Overlay de carga general (opcional, extra feedback)
      bottomNavigationBar: null, // kept for structure integrity, standard scaffold
    );
  }
}
