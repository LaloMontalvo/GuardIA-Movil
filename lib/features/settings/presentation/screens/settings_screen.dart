import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/app_providers.dart';
import '../../../../app/theme/app_colors.dart';

/// Pantalla de Ajustes — premium settings hub
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  Widget _staggered(int index, Widget child) {
    final start = (index * 0.1).clamp(0.0, 0.7);
    final end = (start + 0.4).clamp(0.0, 1.0);
    final fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _staggerCtrl, curve: Interval(start, end, curve: Curves.easeOut)),
    );
    final slide = Tween<Offset>(begin: const Offset(0, 24), end: Offset.zero).animate(
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Premium gradient AppBar ──
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Ajustes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              background: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : AppColors.primaryBlue,
                ),
              ),
            ),
          ),

          // ── Body ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Apariencia ──
                _staggered(0, _sectionLabel(theme, Icons.palette_outlined, 'Apariencia')),
                const SizedBox(height: 8),
                _staggered(1, _settingsCard(
                  isDark: isDark,
                  children: [
                    _settingsTile(
                      icon: Icons.brightness_6_rounded,
                      color: Colors.deepPurple,
                      title: 'Tema',
                      subtitle: _getThemeModeLabel(themeMode),
                      onTap: () => _showThemeDialog(context, ref, themeMode),
                    ),
                    _divider(),
                    _settingsTile(
                      icon: Icons.language_rounded,
                      color: Colors.blue,
                      title: 'Idioma',
                      subtitle: 'Español',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Solo español disponible por ahora')),
                        );
                      },
                    ),
                    _divider(),
                    _settingsTile(
                      icon: Icons.calendar_month_rounded,
                      color: Colors.teal,
                      title: 'Formato de fecha',
                      subtitle: 'DD/MM/YYYY',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Formato actualizado')),
                        );
                      },
                    ),
                  ],
                )),

                const SizedBox(height: 24),

                // ── Streaming y datos ──
                _staggered(2, _sectionLabel(theme, Icons.stream_rounded, 'Streaming y datos')),
                const SizedBox(height: 8),
                _staggered(3, _settingsCard(
                  isDark: isDark,
                  children: [
                    _switchTile(
                      icon: Icons.wifi_rounded,
                      color: Colors.green,
                      title: 'Solo WiFi para streaming',
                      subtitle: 'Ahorra datos móviles',
                      value: ref.watch(wifiOnlyProvider),
                      onChanged: (value) {
                        ref.read(wifiOnlyProvider.notifier).state = value;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(value ? 'Solo WiFi activado' : 'Datos móviles permitidos')),
                        );
                      },
                    ),
                    _divider(),
                    _settingsTile(
                      icon: Icons.high_quality_rounded,
                      color: Colors.indigo,
                      title: 'Calidad de streaming',
                      subtitle: _getQualityLabel(ref.watch(streamQualityProvider)),
                      onTap: () => _showQualityDialog(context, ref),
                    ),
                  ],
                )),

                const SizedBox(height: 24),

                // ── Notificaciones ──
                _staggered(4, _sectionLabel(theme, Icons.notifications_outlined, 'Notificaciones')),
                const SizedBox(height: 8),
                _staggered(5, _settingsCard(
                  isDark: isDark,
                  children: [
                    _settingsTile(
                      icon: Icons.notifications_active_rounded,
                      color: Colors.amber.shade700,
                      title: 'Preferencias de notificación',
                      subtitle: 'Tipos, canales, horarios DND',
                      onTap: () => context.push('/notification-preferences'),
                    ),
                  ],
                )),

                const SizedBox(height: 24),

                // ── Accesibilidad ──
                _staggered(6, _sectionLabel(theme, Icons.accessibility_new_rounded, 'Accesibilidad')),
                const SizedBox(height: 8),
                _staggered(7, _settingsCard(
                  isDark: isDark,
                  children: [
                    _switchTile(
                      icon: Icons.text_increase_rounded,
                      color: Colors.orange,
                      title: 'Texto grande',
                      subtitle: 'Aumenta el tamaño de fuente',
                      value: ref.watch(largeTextProvider),
                      onChanged: (v) => ref.read(largeTextProvider.notifier).state = v,
                    ),
                    _divider(),
                    _switchTile(
                      icon: Icons.contrast_rounded,
                      color: Colors.blueGrey,
                      title: 'Alto contraste',
                      subtitle: 'Aumenta el contraste de colores',
                      value: ref.watch(highContrastProvider),
                      onChanged: (v) => ref.read(highContrastProvider.notifier).state = v,
                    ),
                  ],
                )),

                const SizedBox(height: 24),

                // ── Cuenta y seguridad ──
                _staggered(8, _sectionLabel(theme, Icons.shield_outlined, 'Cuenta y seguridad')),
                const SizedBox(height: 8),
                _staggered(9, _settingsCard(
                  isDark: isDark,
                  children: [
                    _settingsTile(
                      icon: Icons.lock_rounded,
                      color: Colors.red.shade400,
                      title: 'Seguridad',
                      subtitle: 'Contraseña, PIN, biometría, sesiones',
                      onTap: () => context.push('/security'),
                    ),
                    _divider(),
                    _settingsTile(
                      icon: Icons.privacy_tip_rounded,
                      color: Colors.cyan,
                      title: 'Privacidad',
                      subtitle: 'Permisos, datos, documentos legales',
                      onTap: () => context.push('/privacy'),
                    ),
                    _divider(),
                    _settingsTile(
                      icon: Icons.storage_rounded,
                      color: Colors.deepOrange,
                      title: 'Almacenamiento',
                      subtitle: 'Caché, descargas, limpiar datos',
                      onTap: () => context.push('/storage'),
                    ),
                  ],
                )),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section label with icon ──
  Widget _sectionLabel(ThemeData theme, IconData icon, String title) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDark ? Colors.white : AppColors.primaryBlue),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: isDark ? Colors.white : AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Card container ──
  Widget _settingsCard({required bool isDark, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  // ── Settings tile ──
  Widget _settingsTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
      trailing: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey.shade400),
      ),
      onTap: onTap,
    );
  }

  // ── Switch tile ──
  Widget _switchTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
      value: value,
      activeColor: AppColors.primaryBlue,
      onChanged: onChanged,
    );
  }

  Widget _divider() => Divider(height: 1, indent: 72, endIndent: 16, color: Colors.grey.withOpacity(0.15));

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'Claro';
      case ThemeMode.dark: return 'Oscuro';
      case ThemeMode.system: return 'Automático (sistema)';
    }
  }

  String _getQualityLabel(String quality) {
    switch (quality) {
      case 'high': return 'Alta';
      case 'medium': return 'Media';
      case 'low': return 'Baja';
      default: return 'Automática';
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, ThemeMode current) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.brightness_6_rounded, color: isDark ? Colors.white : AppColors.primaryBlue),
            const SizedBox(width: 10),
            const Text('Tema'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _themeOption(ctx, ref, 'Automático', Icons.phone_android,
                ThemeMode.system, current),
            _themeOption(ctx, ref, 'Claro', Icons.light_mode,
                ThemeMode.light, current),
            _themeOption(ctx, ref, 'Oscuro', Icons.dark_mode,
                ThemeMode.dark, current),
          ],
        ),
      ),
    );
  }

  Widget _themeOption(BuildContext ctx, WidgetRef ref, String label,
      IconData icon, ThemeMode value, ThemeMode current) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final isSelected = value == current;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Icon(icon, color: isSelected ? AppColors.primaryBlue : Colors.grey),
          title: Text(label, style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.primaryBlue : null,
          )),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: isDark ? AppColors.accentCyan : AppColors.primaryBlue)
              : null,
          onTap: () {
            ref.read(themeModeProvider.notifier).setTheme(value);
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  void _showQualityDialog(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final current = ref.read(streamQualityProvider);
    final options = [
      {'key': 'auto', 'label': 'Automática', 'icon': Icons.auto_awesome},
      {'key': 'high', 'label': 'Alta', 'icon': Icons.hd},
      {'key': 'medium', 'label': 'Media', 'icon': Icons.sd},
      {'key': 'low', 'label': 'Baja', 'icon': Icons.low_priority},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.high_quality_rounded, color: isDark ? Colors.white : AppColors.primaryBlue),
            const SizedBox(width: 10),
            const Text('Calidad'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            final key = opt['key'] as String;
            final isSelected = key == current;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Material(
                color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: Icon(opt['icon'] as IconData,
                      color: isSelected ? AppColors.primaryBlue : Colors.grey),
                  title: Text(opt['label'] as String, style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppColors.primaryBlue : null,
                  )),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: isDark ? AppColors.accentCyan : AppColors.primaryBlue)
                      : null,
                  onTap: () {
                    ref.read(streamQualityProvider.notifier).state = key;
                    Navigator.pop(ctx);
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
