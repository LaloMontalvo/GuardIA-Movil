import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math' as math;
import '../providers/auth_providers.dart';
import '../../../../core/di/app_providers.dart';
import '../../../../app/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de splash con animaciones y verificación de autenticación
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _contentController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _loaderOpacity;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Logo: scale + fade in
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Content: slide up + fade in
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeIn),
      ),
    );
    _loaderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Pulse glow on logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    _contentController.forward();
    _pulseController.repeat(reverse: true);

    // Navigate after animations
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    _navigateNext();
  }

  Future<void> _navigateNext() async {
    final storage = ref.read(localStorageProvider);
    final hasSeenOnboarding = await storage.hasSeenOnboarding();
    final guard = ref.read(authGuardProvider);

    if (!mounted) return;

    if (!hasSeenOnboarding) {
      context.go('/onboarding');
    } else if (guard.isLoggedIn) {
      // Cargar persistencia del 2FA (y otros) de forma asíncrona
      await ref.read(sessionServiceProvider).init();
      // Validar perfil Firestore antes de permitir acceso
      try {
        await guard.validateProfile();
        guard.markInitialCheckDone();

        if (!mounted) return;

        if (guard.isProfileValid) {
          if (!ref.read(sessionServiceProvider).is2faVerified) {
             context.go('/two-factor');
          } else {
             context.go('/home'); // Router lo redirigirá adecuadamente dependiendo si es operator o admin
          }
        } else {
          context.go('/login');
        }
      } catch (e) {
        if (!mounted) return;
        context.go('/login');
      }
    } else {
      guard.markInitialCheckDone();
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue,
              AppColors.primaryBlueDark,
              AppColors.accentCyan,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo with pulse glow
              AnimatedBuilder(
                animation: Listenable.merge([_logoController, _pulseController]),
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow effect
                          Transform.scale(
                            scale: _pulseScale.value,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentCyan.withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withOpacity(0.2),
                                    blurRadius: 50,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Logo container
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                          child: Image.asset('assets/GuardIA.png', width: 60, height: 60),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Animated Title
              AnimatedBuilder(
                animation: _contentController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _titleSlide,
                    child: Opacity(
                      opacity: _titleOpacity.value,
                      child: Text(
                        'GuardIA',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),

              // Animated Subtitle
              AnimatedBuilder(
                animation: _contentController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _subtitleSlide,
                    child: Opacity(
                      opacity: _subtitleOpacity.value,
                      child: Text(
                        'Videovigilancia Inteligente',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 1,
                            ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),

              // Animated Loader
              AnimatedBuilder(
                animation: _contentController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _loaderOpacity.value,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Preparando tu experiencia...',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
