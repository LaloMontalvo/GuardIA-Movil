import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/app_providers.dart';
import '../providers/auth_providers.dart';

/// Pantalla de bienvenida después de login/registro exitoso
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;

  late Animation<double> _checkScale;
  late Animation<double> _checkOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _buttonOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _mainController.forward();
    _particleController.repeat();
    _markWelcomeSeen();
  }

  Future<void> _markWelcomeSeen() async {
    final storage = ref.read(localStorageProvider);
    await storage.setWelcomeSeen(true);
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );
    _checkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
    ));
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.5, curve: Curves.easeIn),
      ),
    );

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
    ));
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.6, curve: Curves.easeIn),
      ),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _goToHome() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final userName = authState.user?.name ?? 'Usuario';

    return Scaffold(
      body: Stack(
        children: [
          // Solid background
          Container(
            color: AppColors.primaryBlue,
          ),

          // Animated particles
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
            child: Center(
              child: AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),

                      // Animated check icon
                      Opacity(
                        opacity: _checkOpacity.value,
                        child: Transform.scale(
                          scale: _checkScale.value,
                          child: Container(
                            width: 120,
                            height: 120,
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
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Title
                      SlideTransition(
                        position: _titleSlide,
                        child: Opacity(
                          opacity: _titleOpacity.value,
                          child: Text(
                            '¡Bienvenido!',
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // User name
                      SlideTransition(
                        position: _subtitleSlide,
                        child: Opacity(
                          opacity: _subtitleOpacity.value,
                          child: Column(
                            children: [
                              Text(
                                userName,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: AppColors.accentCyan,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  'Tu comunidad está más segura con GuardIA. '
                                  'Comienza a monitorear tus cámaras y recibir alertas en tiempo real.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color:
                                            Colors.white.withOpacity(0.85),
                                        height: 1.5,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Start button
                      Opacity(
                        opacity: _buttonOpacity.value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _goToHome,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 5,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Empezar a explorar',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: AppColors.primaryBlue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter for celebration particles
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
