import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Ajustes — compartido entre Operador y Administrador
class OperatorSettingsScreen extends ConsumerStatefulWidget {
  const OperatorSettingsScreen({super.key});

  @override
  ConsumerState<OperatorSettingsScreen> createState() => _OperatorSettingsScreenState();
}

class _OperatorSettingsScreenState extends ConsumerState<OperatorSettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerCtrl;

  bool _pushNotifications = true;
  bool _panicNotifications = true;
  bool _incidentNotifications = true;
  bool _backgroundLocation = true;
  bool _shareLocation = false;
  bool _biometric = false;
  bool _lowDataMode = false;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  Widget _animatedSection(int index, Widget child) {
    final start = index * 0.1;
    final end = (start + 0.4).clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: _staggerCtrl,
      builder: (context, _) {
        final progress = Curves.easeOutCubic.transform(
          (((_staggerCtrl.value - start) / (end - start)).clamp(0.0, 1.0)),
        );
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - progress)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Ajustes',
                  style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF1A1A3E), const Color(0xFF0F0F1F)]
                        : [Colors.white, Colors.grey.shade50],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Perfil
                _animatedSection(0, _buildProfileCard(user, theme, isDark)),
                const SizedBox(height: 20),

                // Notificaciones
                _animatedSection(1, _buildSection(
                  theme, isDark, 'Notificaciones', Icons.notifications_rounded, Colors.orange,
                  [
                    _SettingsTile(
                      icon: Icons.notifications_active_rounded,
                      title: 'Notificaciones push',
                      subtitle: 'Recibir alertas en tiempo real',
                      trailing: Switch(
                        value: _pushNotifications,
                        onChanged: (v) => setState(() => _pushNotifications = v),
                        activeColor: AppColors.primaryBlue,
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.emergency_rounded,
                      title: 'Alertas de pánico',
                      subtitle: 'Siempre notificar alertas de pánico',
                      trailing: Switch(
                        value: _panicNotifications,
                        onChanged: (v) => setState(() => _panicNotifications = v),
                        activeColor: Colors.red,
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.warning_amber_rounded,
                      title: 'Incidentes de mi zona',
                      subtitle: 'Recibir incidentes cercanos',
                      trailing: Switch(
                        value: _incidentNotifications,
                        onChanged: (v) => setState(() => _incidentNotifications = v),
                        activeColor: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 20),

                // Ubicación
                _animatedSection(2, _buildSection(
                  theme, isDark, 'Ubicación', Icons.location_on_rounded, Colors.green,
                  [
                    _SettingsTile(
                      icon: Icons.my_location_rounded,
                      title: 'Ubicación en segundo plano',
                      subtitle: 'Necesaria para alertas de pánico',
                      trailing: Switch(
                        value: _backgroundLocation,
                        onChanged: (v) => setState(() => _backgroundLocation = v),
                        activeColor: Colors.green,
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.share_location_rounded,
                      title: 'Compartir ubicación',
                      subtitle: 'Visible para supervisores',
                      trailing: Switch(
                        value: _shareLocation,
                        onChanged: (v) => setState(() => _shareLocation = v),
                        activeColor: Colors.green,
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 20),

                // Privacidad
                _animatedSection(3, _buildSection(
                  theme, isDark, 'Privacidad y Seguridad', Icons.lock_rounded, Colors.purple,
                  [
                    _SettingsTile(
                      icon: Icons.fingerprint_rounded,
                      title: 'Autenticación biométrica',
                      subtitle: 'Usar huella o Face ID',
                      trailing: Switch(
                        value: _biometric,
                        onChanged: (v) => setState(() => _biometric = v),
                        activeColor: AppColors.primaryBlue,
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.key_rounded,
                      title: 'Cambiar contraseña',
                      onTap: () {},
                    ),
                  ],
                )),
                const SizedBox(height: 20),

                // Datos y Rendimiento
                _animatedSection(4, _buildSection(
                  theme, isDark, 'Datos y Rendimiento', Icons.speed_rounded, Colors.teal,
                  [
                    _SettingsTile(
                      icon: Icons.data_saver_on_rounded,
                      title: 'Modo ahorro de datos',
                      subtitle: 'Reduce calidad de streaming',
                      trailing: Switch(
                        value: _lowDataMode,
                        onChanged: (v) => setState(() => _lowDataMode = v),
                        activeColor: AppColors.primaryBlue,
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.cleaning_services_rounded,
                      title: 'Limpiar caché',
                      subtitle: '23 MB en uso',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Caché limpiado'))),
                    ),
                  ],
                )),
                const SizedBox(height: 20),

                // Soporte
                _animatedSection(5, _buildSection(
                  theme, isDark, 'Soporte', Icons.help_outline_rounded, AppColors.primaryBlue,
                  [
                    _SettingsTile(icon: Icons.contact_support_rounded, title: 'Contactar soporte', onTap: () {}),
                    _SettingsTile(icon: Icons.bug_report_rounded, title: 'Reportar un problema', onTap: () {}),
                    _SettingsTile(icon: Icons.info_outline_rounded, title: 'Acerca de GuardIA', onTap: () {}),
                  ],
                )),
                const SizedBox(height: 20),

                // Cerrar sesión
                _animatedSection(6, SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Cerrar sesión'),
                          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(dialogContext, true),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                              child: const Text('Cerrar sesión'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        ref.read(authStateProvider.notifier).logout();
                        context.go('/login');
                      }
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Cerrar sesión', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                )),
                const SizedBox(height: 16),
                Center(
                  child: Text('GuardIA v1.0.0',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(dynamic user, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E3E), const Color(0xFF2A2A4E)]
              : [AppColors.primaryBlue, const Color(0xFF4A6CF7)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              (user?.name ?? 'O')[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.name ?? 'Operador',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                Text(user?.email ?? 'operador@guardia.com',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(user?.role.displayName ?? 'Usuario',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.edit_rounded, color: Colors.white.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, bool isDark, String title, IconData icon, Color iconColor,
      List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Colors.grey.shade600),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(fontSize: 12, color: Colors.grey.shade500))
          : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded, size: 20) : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      dense: true,
    );
  }
}
