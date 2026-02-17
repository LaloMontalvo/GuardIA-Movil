import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/app_providers.dart';

/// Pantalla de onboarding con slides explicativos y colores del sistema
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      icon: Icons.videocam_rounded,
      title: 'Monitoreo en Vivo',
      description:
          'Vigila tus cámaras en tiempo real desde cualquier lugar con transmisión segura y de alta calidad.',
      primaryColor: AppColors.primaryBlue,
      secondaryColor: AppColors.accentCyan,
    ),
    _OnboardingData(
      icon: Icons.notifications_active_rounded,
      title: 'Alertas Inteligentes',
      description:
          'Recibe notificaciones instantáneas de intrusiones, incendios y eventos sospechosos detectados por IA.',
      primaryColor: AppColors.accentCyan,
      secondaryColor: AppColors.primaryBlue,
    ),
    _OnboardingData(
      icon: Icons.map_rounded,
      title: 'Mapa Interactivo',
      description:
          'Visualiza todas tus cámaras y alertas en un mapa interactivo para una gestión eficiente de tu zona.',
      primaryColor: AppColors.primaryBlue,
      secondaryColor: AppColors.primaryBlueLight,
    ),
    _OnboardingData(
      icon: Icons.folder_special_rounded,
      title: 'Evidencia Segura',
      description:
          'Guarda, recorta y exporta grabaciones como evidencia. Organiza por casos y comparte de forma segura.',
      primaryColor: AppColors.primaryBlueDark,
      secondaryColor: AppColors.accentCyan,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final storage = ref.read(localStorageProvider);
    await storage.setOnboardingSeen(true);
    if (mounted) {
      context.go('/permissions');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _finishOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                    ),
                    child: const Text('Saltar'),
                  ),
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated icon with gradient circle
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  page.primaryColor.withOpacity(0.15),
                                  page.secondaryColor.withOpacity(0.1),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: page.primaryColor.withOpacity(0.1),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              page.icon,
                              size: 75,
                              color: isDark ? AppColors.accentCyan : page.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 48),
                          Text(
                            page.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.primaryBlue,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                  height: 1.5,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Dots indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: _currentPage == index
                            ? const LinearGradient(
                                colors: [
                                  AppColors.primaryBlue,
                                  AppColors.accentCyan,
                                ],
                              )
                            : null,
                        color: _currentPage == index
                            ? null
                            : AppColors.primaryBlue.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Empezar'
                          : 'Siguiente',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
  });
}
