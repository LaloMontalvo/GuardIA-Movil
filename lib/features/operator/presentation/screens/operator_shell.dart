import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';

/// Shell principal del Operador con BottomNavigation de 5 tabs
class OperatorShell extends StatelessWidget {
  final Widget child;
  const OperatorShell({super.key, required this.child});

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
                _OperatorNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Inicio',
                  isActive: selectedIndex == 0,
                  onTap: () => context.go('/operator-home'),
                ),
                _OperatorNavItem(
                  icon: Icons.edit_note_outlined,
                  activeIcon: Icons.edit_note_rounded,
                  label: 'Reportar',
                  isActive: selectedIndex == 1,
                  onTap: () => context.go('/operator-report'),
                ),
                _OperatorNavItem(
                  icon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications_rounded,
                  label: 'Avisos',
                  isActive: selectedIndex == 2,
                  onTap: () => context.go('/operator-notifications'),
                ),
                _OperatorNavItem(
                  icon: Icons.videocam_outlined,
                  activeIcon: Icons.videocam_rounded,
                  label: 'Mi Cámara',
                  isActive: selectedIndex == 3,
                  onTap: () => context.go('/operator-camera'),
                ),
                _OperatorNavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: 'Ajustes',
                  isActive: selectedIndex == 4,
                  onTap: () => context.go('/operator-settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getIndexFromPath(String path) {
    if (path.startsWith('/operator-home')) return 0;
    if (path.startsWith('/operator-report')) return 1;
    if (path.startsWith('/operator-notifications')) return 2;
    if (path.startsWith('/operator-camera')) return 3;
    if (path.startsWith('/operator-settings')) return 4;
    return 0;
  }
}

/// Individual nav item con indicador animado (mismo estilo premium que Supervisor)
class _OperatorNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _OperatorNavItem({
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
          horizontal: isActive ? 14 : 10,
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
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : AppColors.primaryBlue)
                    : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: isActive ? 10 : 9,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : AppColors.primaryBlue)
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
