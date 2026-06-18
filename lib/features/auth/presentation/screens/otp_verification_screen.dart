import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../../../app/theme/app_colors.dart';

/// Pantalla de verificación OTP
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  int _resendTimer = 60;
  bool _canResend = false;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _resendTimer--;
        if (_resendTimer <= 0) _canResend = true;
      });
      return _resendTimer > 0;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _particleController.dispose();
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el código completo')),
      );
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verificación exitosa'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/login');
    }
  }

  void _resendCode() {
    setState(() {
      _resendTimer = 60;
      _canResend = false;
    });
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Código reenviado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Same blue background as welcome screen
          Container(
            color: AppColors.primaryBlue,
          ),

          // Animated particles (same as welcome screen)
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ParticlePainter(
                  progress: _particleController.value,
                ),
              );
            },
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // AppBar area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        'Verificación',
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
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // App logo
                          Container(
                            width: 90,
                            height: 90,
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
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          const Text(
                            'Ingresa el código',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hemos enviado un código de 6 dígitos\na tu correo electrónico.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.75),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 36),

                          // OTP input fields
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (index) {
                              return SizedBox(
                                width: 46,
                                height: 56,
                                child: TextFormField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    contentPadding: EdgeInsets.zero,
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.25),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.25),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.accentCyan,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  cursorColor: AppColors.accentCyan,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onChanged: (value) {
                                    if (value.isNotEmpty && index < 5) {
                                      _focusNodes[index + 1].requestFocus();
                                    }
                                    if (value.isEmpty && index > 0) {
                                      _focusNodes[index - 1].requestFocus();
                                    }
                                  },
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 36),

                          // Verify button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _verify,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primaryBlue,
                                disabledBackgroundColor: Colors.white.withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 5,
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Verificar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Resend
                          _canResend
                              ? TextButton(
                                  onPressed: _resendCode,
                                  child: const Text(
                                    'Reenviar código',
                                    style: TextStyle(
                                      color: AppColors.accentCyan,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Reenviar código en ${_resendTimer}s',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 14,
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

/// Painter for floating particles (same as welcome screen)
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
      final opacity =
          (0.2 + 0.3 * math.sin(progress * math.pi * 2 + phase)).clamp(0.0, 1.0);

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
