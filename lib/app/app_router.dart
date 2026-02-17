import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Auth & Security
import '../features/auth/presentation/providers/auth_providers.dart';
import 'auth/auth_guard.dart';
import '../core/widgets/app_alerts.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
// Register removed — users are pre-registered via admin dashboard
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/permissions_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/otp_verification_screen.dart';
import '../features/auth/presentation/screens/zone_selection_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/auth/presentation/screens/maintenance_screen.dart';

// Main tabs
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/cameras/presentation/screens/cameras_list_screen.dart';
import '../features/alerts/presentation/screens/alerts_list_screen.dart';
import '../features/map/presentation/screens/map_screen.dart';
import '../features/settings/presentation/screens/more_screen.dart';

// Camera screens
import '../features/cameras/presentation/screens/camera_detail_screen.dart';
import '../features/cameras/presentation/screens/live_view_screen.dart';
import '../features/cameras/presentation/screens/multi_camera_screen.dart';

// Alert screens
import '../features/alerts/presentation/screens/alert_detail_screen.dart';
import '../features/alerts/presentation/screens/create_incident_screen.dart';
import '../features/alerts/presentation/screens/panic_screen.dart';

// Recordings
import '../features/recordings/presentation/screens/recordings_list_screen.dart';
import '../features/recordings/presentation/screens/evidence_screen.dart';

// Notifications
import '../features/notifications/presentation/screens/notifications_screen.dart';

// Reports
import '../features/reports/presentation/screens/reports_screen.dart';
import '../features/reports/presentation/screens/my_reports_screen.dart';
import '../features/reports/presentation/screens/report_confirmation_screen.dart';

// Settings & Profile
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/privacy_screen.dart';
import '../features/settings/presentation/screens/security_screen.dart';
import '../features/settings/presentation/screens/storage_screen.dart';

// Help
import '../features/help/presentation/screens/help_screen.dart';
import '../features/help/presentation/screens/about_screen.dart';

// Theme
import 'theme/app_colors.dart';

/// Custom page transition — fade + slide up
CustomTransitionPage<void> _buildAnimatedPage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnim = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curvedAnim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curvedAnim),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

/// Rutas que no requieren autenticación
const _publicRoutes = [
  '/',
  '/login',
  '/onboarding',
  '/permissions',
  '/forgot-password',
  '/verify-otp',
  '/zone-selection',
  '/welcome',
  '/maintenance',
];

/// Clave global para mostrar SnackBars desde el redirect
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Provider del router con protección anti-spoofing
final routerProvider = Provider<GoRouter>((ref) {
  final guard = ref.watch(authGuardProvider);
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: guard,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isPublicRoute = _publicRoutes.contains(loc);

      // --- Caso 1: No autenticado intentando acceder a ruta protegida ---
      if (!guard.isLoggedIn && !isPublicRoute) {
        // Mostrar razón de redirección si existe
        _showRedirectReason(guard);
        return '/login';
      }

      // --- Caso 2: Autenticado pero perfil Firestore inválido ---
      if (guard.isLoggedIn &&
          guard.initialCheckDone &&
          !guard.isProfileValid &&
          !isPublicRoute) {
        _showRedirectReason(guard);
        return '/login';
      }

      // --- Caso 3: Ya autenticado con perfil válido en /login ---
      if (guard.isLoggedIn &&
          guard.isProfileValid &&
          loc == '/login') {
        return '/home';
      }

      // Fallback: también verificar el estado Riverpod por compatibilidad
      if (!authState.isAuthenticated && !isPublicRoute) {
        return '/login';
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

      // Auth routes
      GoRoute(path: '/login', pageBuilder: (context, state) => _buildAnimatedPage(const LoginScreen(), state)),
      // Register route removed — users are pre-registered via admin dashboard
      GoRoute(path: '/onboarding', pageBuilder: (context, state) => _buildAnimatedPage(const OnboardingScreen(), state)),
      GoRoute(path: '/permissions', pageBuilder: (context, state) => _buildAnimatedPage(const PermissionsScreen(), state)),
      GoRoute(path: '/forgot-password', pageBuilder: (context, state) => _buildAnimatedPage(const ForgotPasswordScreen(), state)),
      GoRoute(path: '/verify-otp', pageBuilder: (context, state) => _buildAnimatedPage(const OtpVerificationScreen(), state)),
      GoRoute(path: '/zone-selection', pageBuilder: (context, state) => _buildAnimatedPage(const ZoneSelectionScreen(), state)),
      GoRoute(path: '/welcome', pageBuilder: (context, state) => _buildAnimatedPage(const WelcomeScreen(), state)),
      GoRoute(path: '/maintenance', pageBuilder: (context, state) => _buildAnimatedPage(const MaintenanceScreen(), state)),

      // Main App with Bottom Navigation (5 tabs)
      ShellRoute(
        builder: (context, state, child) => _MainScaffold(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/cameras', builder: (context, state) => const CamerasListScreen()),
          GoRoute(path: '/alerts', builder: (context, state) => const AlertsListScreen()),
          GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
          GoRoute(path: '/more', builder: (context, state) => const MoreScreen()),
        ],
      ),

      // Camera sub-routes
      GoRoute(
        path: '/camera/:id',
        pageBuilder: (context, state) => _buildAnimatedPage(
          CameraDetailScreen(cameraId: state.pathParameters['id']!), state),
      ),
      GoRoute(
        path: '/camera/:id/live',
        pageBuilder: (context, state) => _buildAnimatedPage(
          LiveViewScreen(cameraId: state.pathParameters['id']!), state),
      ),
      GoRoute(path: '/cameras/multi', pageBuilder: (context, state) => _buildAnimatedPage(const MultiCameraScreen(), state)),

      // Alert sub-routes
      GoRoute(
        path: '/alert/:id',
        pageBuilder: (context, state) => _buildAnimatedPage(
          AlertDetailScreen(alertId: state.pathParameters['id']!), state),
      ),
      GoRoute(path: '/create-incident', pageBuilder: (context, state) => _buildAnimatedPage(const CreateIncidentScreen(), state)),
      GoRoute(path: '/panic', pageBuilder: (context, state) => _buildAnimatedPage(const PanicScreen(), state)),

      // Recordings & Evidence
      GoRoute(path: '/recordings', pageBuilder: (context, state) => _buildAnimatedPage(const RecordingsListScreen(), state)),
      GoRoute(
        path: '/recording/:id',
        pageBuilder: (context, state) => _buildAnimatedPage(
          RecordingPlayerScreen(recordingId: state.pathParameters['id']!), state),
      ),
      GoRoute(path: '/evidence', pageBuilder: (context, state) => _buildAnimatedPage(const EvidenceScreen(), state)),

      // Notifications
      GoRoute(path: '/notifications', pageBuilder: (context, state) => _buildAnimatedPage(const NotificationsScreen(), state)),
      GoRoute(path: '/notification-preferences', pageBuilder: (context, state) => _buildAnimatedPage(const NotificationPreferencesScreen(), state)),

      // Reports (Vecino)
      GoRoute(path: '/reports', pageBuilder: (context, state) => _buildAnimatedPage(const ReportsScreen(), state)),
      GoRoute(path: '/my-reports', pageBuilder: (context, state) => _buildAnimatedPage(const MyReportsScreen(), state)),
      GoRoute(
        path: '/report-confirmation/:folio',
        pageBuilder: (context, state) => _buildAnimatedPage(
          ReportConfirmationScreen(folio: state.pathParameters['folio'] ?? 'N/A'), state),
      ),

      // Settings & Profile
      GoRoute(path: '/settings', pageBuilder: (context, state) => _buildAnimatedPage(const SettingsScreen(), state)),
      GoRoute(path: '/profile', pageBuilder: (context, state) => _buildAnimatedPage(const ProfileScreen(), state)),
      GoRoute(path: '/privacy', pageBuilder: (context, state) => _buildAnimatedPage(const PrivacyScreen(), state)),
      GoRoute(path: '/security', pageBuilder: (context, state) => _buildAnimatedPage(const SecurityScreen(), state)),
      GoRoute(path: '/storage', pageBuilder: (context, state) => _buildAnimatedPage(const StorageScreen(), state)),

      // Help & About
      GoRoute(path: '/help', pageBuilder: (context, state) => _buildAnimatedPage(const HelpScreen(), state)),
      GoRoute(path: '/about', pageBuilder: (context, state) => _buildAnimatedPage(const AboutScreen(), state)),
      GoRoute(path: '/help/ticket', pageBuilder: (context, state) => _buildAnimatedPage(const CreateTicketScreen(), state)),
    ],
  );
});

/// Muestra una alerta premium con la razón de redirección
void _showRedirectReason(AuthGuard guard) {
  final reason = guard.redirectReason;
  if (reason == null) return;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx != null) {
      AppAlerts.showSnackBar(
        ctx,
        title: 'Acceso denegado',
        message: reason,
        type: AlertType.warning,
        duration: const Duration(seconds: 5),
      );
    }
    guard.clearRedirectReason();
  });
}

/// Premium bottom navigation with gradient accent
class _MainScaffold extends StatelessWidget {
  final Widget child;
  const _MainScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _getIndexFromPath(currentPath);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Inicio',
                  isActive: selectedIndex == 0,
                  onTap: () => context.go('/home'),
                ),
                _NavItem(
                  icon: Icons.videocam_outlined,
                  activeIcon: Icons.videocam_rounded,
                  label: 'Cámaras',
                  isActive: selectedIndex == 1,
                  onTap: () => context.go('/cameras'),
                ),
                _NavItem(
                  icon: Icons.warning_amber_rounded,
                  activeIcon: Icons.warning_rounded,
                  label: 'Alertas',
                  isActive: selectedIndex == 2,
                  onTap: () => context.go('/alerts'),
                ),
                _NavItem(
                  icon: Icons.map_outlined,
                  activeIcon: Icons.map_rounded,
                  label: 'Mapa',
                  isActive: selectedIndex == 3,
                  onTap: () => context.go('/map'),
                ),
                _NavItem(
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view_rounded,
                  label: 'Más',
                  isActive: selectedIndex == 4,
                  onTap: () => context.go('/more'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getIndexFromPath(String path) {
    if (path.startsWith('/home')) return 0;
    if (path.startsWith('/cameras')) return 1;
    if (path.startsWith('/alerts')) return 2;
    if (path.startsWith('/map')) return 3;
    if (path.startsWith('/more')) return 4;
    return 0;
  }
}

/// Individual nav item with animated indicator
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isActive
              ? const LinearGradient(
                  colors: [
                    Color(0x20081221),
                    Color(0x1000C6FF),
                  ],
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                size: isActive ? 26 : 24,
                color: isActive
                    ? AppColors.primaryBlue
                    : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: isActive ? 11 : 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? AppColors.primaryBlue
                    : Colors.grey.shade500,
              ),
              child: Text(label),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              width: isActive ? 20 : 0,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: isActive
                    ? const LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.accentCyan],
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
