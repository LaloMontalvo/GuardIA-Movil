import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../app/theme/app_colors.dart';

/// More screen — premium settings hub with animated menu items
class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  Widget _staggeredItem(int index, Widget child) {
    final start = (index * 0.08).clamp(0.0, 0.8);
    final end = (start + 0.4).clamp(0.0, 1.0);
    final fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _staggerCtrl, curve: Interval(start, end, curve: Curves.easeOut)),
    );
    final slide = Tween<Offset>(begin: const Offset(0, 20), end: Offset.zero).animate(
      CurvedAnimation(parent: _staggerCtrl, curve: Interval(start, end, curve: Curves.easeOutCubic)),
    );
    return AnimatedBuilder(
      animation: _staggerCtrl,
      builder: (context, _) => Opacity(
        opacity: fade.value,
        child: Transform.translate(offset: slide.value, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final menuSections = [
      _MenuSection('General', [
        _MenuItem(Icons.notifications_outlined, 'Notificaciones', 'Centro de alertas', AppColors.accentCyan, () => context.push('/notifications')),
        _MenuItem(Icons.video_library_outlined, 'Grabaciones', 'Historial de video', const Color(0xFFF97316), () => context.push('/recordings')),
        _MenuItem(Icons.assessment_outlined, 'Reportes', 'Generar informes', const Color(0xFF10B981), () => context.push('/reports')),
      ]),
      _MenuSection('Configuración', [
        _MenuItem(Icons.settings_outlined, 'Ajustes', 'Preferencias generales', Colors.grey, () => context.push('/settings')),
        _MenuItem(Icons.help_outline, 'Ayuda', 'Centro de soporte', const Color(0xFF8B5CF6), () => context.push('/help')),
        _MenuItem(Icons.info_outline, 'Acerca de', 'Información de la app', const Color(0xFF3B82F6), () => context.push('/about')),
      ]),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverToBoxAdapter(
            child: _staggeredItem(0, Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16, right: 16, bottom: 8,
              ),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark ? const Color(0xFF1E1E3F) : AppColors.primaryBlue,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentCyan,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentCyan.withValues(alpha: 0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: isDark ? const Color(0xFF1A1A3E) : Colors.white,
                      child: Text(
                        (user?.name ?? 'U')[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Usuario',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? 'correo@guardia.com',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user?.role.displayName ?? 'Vecino',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                      onPressed: () => context.push('/profile'),
                    ),
                  ),
                ],
              ),
            )),
          ),

          // Menu Sections
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, sectionIndex) {
                  final section = menuSections[sectionIndex];
                  return _staggeredItem(sectionIndex + 1, Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, top: 20, bottom: 10),
                        child: Text(
                          section.title.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.08)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: section.items.asMap().entries.map((entry) {
                            final i = entry.key;
                            final item = entry.value;
                            final isLast = i == section.items.length - 1;
                            return Column(
                              children: [
                                _MenuTile(item: item),
                                if (!isLast)
                                  Divider(height: 1, indent: 60,
                                    color: theme.dividerColor.withValues(alpha: 0.08)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ));
                },
                childCount: menuSections.length,
              ),
            ),
          ),

          // Logout + Version
          SliverToBoxAdapter(
            child: _staggeredItem(menuSections.length + 1, Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref.read(authStateProvider.notifier).logout();
                        context.go('/login');
                      },
                      icon: const Icon(Icons.logout_rounded, color: Colors.red),
                      label: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'GuardIA v1.0.0',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }
}

class _MenuSection {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection(this.title, this.items);
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.title, this.subtitle, this.color, this.onTap);
}

class _MenuTile extends StatefulWidget {
  final _MenuItem item;
  const _MenuTile({required this.item});

  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.reverse(),
      onTapUp: (_) {
        _scaleCtrl.forward();
        widget.item.onTap();
      },
      onTapCancel: () => _scaleCtrl.forward(),
      child: ScaleTransition(
        scale: _scaleCtrl,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(widget.item.icon, color: widget.item.color, size: 22),
          ),
          title: Text(widget.item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          subtitle: Text(widget.item.subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
        ),
      ),
    );
  }
}
