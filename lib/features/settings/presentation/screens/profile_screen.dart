import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../app/theme/app_colors.dart';

/// Pantalla de perfil — Premium
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late AnimationController _staggerCtrl;
  String _selectedTz = 'America/Mexico_City';

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).user;
    _nameCtrl = TextEditingController(text: user?.name ?? 'Usuario GuardIA');
    _emailCtrl = TextEditingController(text: user?.email ?? 'user@guardia.com');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '55-1234-5678');
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _staggerCtrl.dispose();
    super.dispose();
  }

  Widget _stagger(int i, Widget child) {
    final s = (i * 0.12).clamp(0.0, 0.7);
    final e = (s + 0.4).clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: _staggerCtrl,
      builder: (ctx, _) {
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _staggerCtrl,
            curve: Interval(s, e, curve: Curves.easeOut),
          ),
        );
        final slide = Tween<Offset>(
          begin: const Offset(0, 20),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _staggerCtrl,
            curve: Interval(s, e, curve: Curves.easeOutCubic),
          ),
        );
        return Opacity(
          opacity: fade.value,
          child: Transform.translate(offset: slide.value, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final role = user?.role.displayName ?? 'Usuario';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gradient AppBar with avatar
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Mi Perfil',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              background: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A3E) : AppColors.primaryBlue,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar with gradient ring
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.accentCyan, AppColors.primaryBlue],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentCyan.withValues(alpha: 0.3),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: isDark
                              ? const Color(0xFF1A1A3E)
                              : Colors.white,
                          child: Text(
                            (user?.name ?? 'A')[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          role,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Form content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Personal info card
                _stagger(
                  0,
                  _fieldCard([
                    _premiumField(_nameCtrl, 'Nombre completo', Icons.person_outline),
                    const Divider(height: 1, indent: 56),
                    _premiumField(
                      _emailCtrl,
                      'Correo electrónico',
                      Icons.email_outlined,
                      enabled: false,
                    ),
                    const Divider(height: 1, indent: 56),
                    _premiumField(_phoneCtrl, 'Teléfono', Icons.phone_outlined),
                    const Divider(height: 1, indent: 56),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedTz,
                        decoration: const InputDecoration(
                          labelText: 'Zona horaria',
                          prefixIcon: Icon(Icons.schedule_outlined),
                          border: InputBorder.none,
                        ),
                        items: [
                          'America/Mexico_City',
                          'America/Cancun',
                          'America/Monterrey',
                          'America/Tijuana',
                        ]
                            .map((tz) => DropdownMenuItem(
                                  value: tz,
                                  child: Text(tz.split('/').last),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedTz = v!),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                // Save button
                _stagger(
                  1,
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.primaryBlue,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Perfil actualizado'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'Guardar cambios',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Security section
                _stagger(
                  2,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.security,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Seguridad',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _fieldCard([
                        ListTile(
                          leading: _iconBox(
                            Icons.lock_outline,
                            AppColors.primaryBlue,
                          ),
                          title: const Text('Cambiar contraseña'),
                          trailing: const Icon(Icons.chevron_right, size: 20),
                          onTap: _showChangePassword,
                        ),
                        Divider(
                          height: 1,
                          indent: 56,
                          color: theme.dividerColor.withValues(alpha: 0.08),
                        ),
                        ListTile(
                          leading: _iconBox(Icons.devices, Colors.orange),
                          title: const Text('Sesiones activas'),
                          subtitle: const Text('2 dispositivos'),
                          trailing: const Icon(Icons.chevron_right, size: 20),
                          onTap: () {},
                        ),
                        Divider(
                          height: 1,
                          indent: 56,
                          color: theme.dividerColor.withValues(alpha: 0.08),
                        ),
                        ListTile(
                          leading: _iconBox(Icons.security, Colors.green),
                          title: const Text('Verificación en dos pasos'),
                          subtitle: const Text('Desactivada'),
                          trailing: Switch(value: false, onChanged: (v) {}),
                        ),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _premiumField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: ctrl,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _fieldCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  void _showChangePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña actual',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nueva contraseña',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contraseña actualizada'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }
}
