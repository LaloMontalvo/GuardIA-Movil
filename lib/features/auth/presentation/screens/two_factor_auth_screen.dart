import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../providers/auth_providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_alerts.dart';

class TwoFactorAuthScreen extends ConsumerStatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  ConsumerState<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends ConsumerState<TwoFactorAuthScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isSendingCode = false;

  @override
  void initState() {
    super.initState();
    // Enviar código automáticamente al mostrar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendCode(isInitial: true);
    });
  }

  Future<void> _sendCode({bool isInitial = false}) async {
    if (!mounted) return;
    setState(() => _isSendingCode = true);
    try {
      String? token;
      for (int i = 0; i < 5; i++) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          token = await user.getIdToken(true);
          if (token != null) break;
        }
        await Future.delayed(const Duration(milliseconds: 400));
      }
      if (token == null) {
        throw Exception('No se pudo verificar la sesión con el servidor.');
      }
      
      final dio = Dio();
      final response = await dio.post(
        'https://us-central1-guardia-ddc04.cloudfunctions.net/beginEmailSecondFactor',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: {'data': {}},
      );
      
      if (response.data != null && response.data['error'] != null) {
        throw Exception(response.data['error']['message'] ?? 'Error desconocido del servidor');
      }
      
      if (mounted && !isInitial) {
        AppAlerts.showSnackBar(
          context,
          title: 'Código reenviado',
          message: 'Revisa tu bandeja de entrada o la carpeta de spam.',
          type: AlertType.success,
        );
      }
    } catch (e) {
      if (mounted && !isInitial) {
        AppAlerts.showSnackBar(
          context,
          title: 'No se pudo enviar el código',
          message: 'Por favor intenta de nuevo en unos momentos.',
          type: AlertType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingCode = false);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      AppAlerts.showSnackBar(
        context,
        title: 'Código incompleto',
        message: 'Por favor, ingresa los 6 dígitos.',
        type: AlertType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final dio = Dio();
      final response = await dio.post(
        'https://us-central1-guardia-ddc04.cloudfunctions.net/verifyEmailSecondFactor',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: {'data': {'code': code}},
      );
      
      if (response.data != null && response.data['error'] != null) {
        throw Exception(response.data['error']['message'] ?? 'Código incorrecto u otro error de servidor');
      }
      
      // Update local 2FA verified state to unlock app routes
      ref.read(authGuardProvider).verify2fa();
      
      if (!mounted) return;
      context.go('/welcome');
    } catch (e) {
      if (!mounted) return;
      
      String errorMsg = 'El código ingresado es incorrecto. Intenta nuevamente.';
      final eStr = e.toString().toLowerCase();
      
      if (e is DioException) {
        final errorData = e.response?.data;
        if (errorData != null && errorData is Map && errorData['error'] != null) {
          final srvMsg = errorData['error']['message'].toString().toLowerCase();
          if (srvMsg.contains('deadline-exceeded') || srvMsg.contains('expirado')) {
            errorMsg = 'El código ha expirado (10 min). Por favor inicia sesión de nuevo.';
          } else if (srvMsg.contains('resource-exhausted') || srvMsg.contains('intentos')) {
            errorMsg = 'Demasiados intentos incorrectos.';
          } else {
            errorMsg = errorData['error']['message'];
          }
        }
      } else {
        if (eStr.contains('deadline-exceeded') || eStr.contains('expirado')) {
          errorMsg = 'El código ha expirado (10 min). Por favor inicia sesión de nuevo.';
        } else if (eStr.contains('resource-exhausted') || eStr.contains('intentos')) {
          errorMsg = 'Demasiados intentos incorrectos.';
        }
      }
      
      AppAlerts.showSnackBar(
        context,
        title: 'Verificación fallida',
        message: errorMsg,
        type: AlertType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Same blue background as welcome screen
          Container(color: AppColors.primaryBlue),

          // Animated particles
          _ParticleBackground(),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        'Verificación de Seguridad',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // App logo
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.15),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentCyan.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/GuardIA.png',
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          const Text(
                            'Hemos enviado un código',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Ingresa el código de 6 dígitos que enviamos a tu correo electrónico registrado para verificar tu identidad.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.75),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),

                          // Code input
                          TextFormField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 32,
                              letterSpacing: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: '000000',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.25),
                                fontSize: 32,
                                letterSpacing: 16,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.25),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.25),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.accentCyan,
                                  width: 2,
                                ),
                              ),
                            ),
                            cursorColor: AppColors.accentCyan,
                            onChanged: (value) {
                              if (value.length == 6) {
                                FocusScope.of(context).unfocus();
                              }
                            },
                          ),
                          const SizedBox(height: 32),

                          // Verify button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _verifyCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primaryBlue,
                                disabledBackgroundColor: Colors.white.withOpacity(0.5),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 5,
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryBlue,
                                      ),
                                    )
                                  : const Text(
                                      'Verificar Código',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Resend button
                          TextButton(
                            onPressed: _isSendingCode ? null : () => _sendCode(isInitial: false),
                            child: _isSendingCode
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.accentCyan,
                                    ),
                                  )
                                : const Text(
                                    'Reenviar código',
                                    style: TextStyle(
                                      color: AppColors.accentCyan,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated floating particles (same as welcome screen)
class _ParticleBackground extends StatefulWidget {
  @override
  State<_ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<_ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _ParticlePainter(progress: _controller.value),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  _ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      AppColors.accentCyan,
      AppColors.primaryBlueLight,
      Colors.white,
      AppColors.accentCyanLight,
    ];
    final random = math.Random(42);
    for (int i = 0; i < 25; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final radius = 2.0 + random.nextDouble() * 4;
      final speed = 0.5 + random.nextDouble();
      final phase = random.nextDouble() * math.pi * 2;
      final x = baseX + math.sin(progress * math.pi * 2 * speed + phase) * 20;
      final y = baseY + math.cos(progress * math.pi * 2 * speed + phase) * 15;
      final opacity = (0.2 + 0.3 * math.sin(progress * math.pi * 2 + phase)).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = colors[i % colors.length].withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
