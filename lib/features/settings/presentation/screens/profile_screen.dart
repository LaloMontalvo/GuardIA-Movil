import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../app/theme/app_colors.dart';

/// Pantalla de perfil — Premium Redesign
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
      duration: const Duration(milliseconds: 800),
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
    final s = (i * 0.1).clamp(0.0, 0.6);
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
          // Expanded Gradient AppBar
          SliverAppBar(
            expandedHeight: 220, // Increased height to prevent overlap
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 16),
                title: const Text(
                  'Mi Perfil',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [const Color(0xFF1A1A3E), const Color(0xFF121212)]
                        : [AppColors.primaryBlue, AppColors.primaryBlueDark],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10), // Reduced top spacing
                      // Avatar with glowing ring
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.accentCyan, AppColors.primaryBlue],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentCyan.withValues(alpha: 0.4),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: isDark
                              ? const Color(0xFF1E1E2C)
                              : Colors.white,
                          child: Text(
                            (user?.name ?? 'A')[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          role,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Form content with improved spacing
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Personal info section
                _stagger(0, _sectionTitle(theme, 'Información Personal')),
                const SizedBox(height: 12),
                _stagger(
                  1,
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.08),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _premiumField(_nameCtrl, 'Nombre completo', Icons.person_outline),
                        _divider(theme),
                        _premiumField(
                          _emailCtrl,
                          'Correo electrónico',
                          Icons.email_outlined,
                          enabled: false,
                        ),
                        _divider(theme),
                        _premiumField(_phoneCtrl, 'Teléfono', Icons.phone_outlined),
                        _divider(theme),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedTz,
                            decoration: InputDecoration(
                              labelText: 'Zona horaria',
                              labelStyle: TextStyle(color: theme.hintColor),
                              prefixIcon: Icon(Icons.schedule_outlined, color: theme.primaryColor),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            icon: Icon(Icons.arrow_drop_down_rounded, color: theme.hintColor),
                            dropdownColor: theme.cardColor,
                            style: theme.textTheme.bodyLarge,
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
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),

                // Save button
                _stagger(
                  2,
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Perfil actualizado correctamente'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: AppColors.primaryBlue.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Guardar cambios',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Security section
                _stagger(3, _sectionTitle(theme, 'Seguridad y Cuenta')),
                const SizedBox(height: 12),
                _stagger(
                  4,
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: _iconBox(
                            Icons.lock_outline,
                            AppColors.primaryBlue,
                          ),
                          title: const Text('Cambiar contraseña', style: TextStyle(fontWeight: FontWeight.w600)),
                          trailing: Icon(Icons.chevron_right, size: 22, color: theme.hintColor),
                          onTap: _showChangePassword,
                        ),
                        _divider(theme),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: _iconBox(Icons.devices_rounded, Colors.orange),
                          title: const Text('Sesiones activas', style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('2 dispositivos', style: TextStyle(color: theme.hintColor, fontSize: 13)),
                          trailing: Icon(Icons.chevron_right, size: 22, color: theme.hintColor),
                          onTap: () {},
                        ),
                        _divider(theme),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: _iconBox(Icons.security_rounded, Colors.green),
                          title: const Text('Verificación en dos pasos', style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Recomendado', style: TextStyle(color: Colors.green.shade700, fontSize: 13, fontWeight: FontWeight.w500)),
                          trailing: Switch.adaptive(
                            value: false, 
                            onChanged: (v) {},
                            activeColor: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Logout (Optional addition given the redesign context)
                _stagger(
                  5,
                  Center(
                    child: TextButton.icon(
                      onPressed: _showLogoutConfirmation,
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text('Cerrar sesión'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
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

  Widget _sectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _divider(ThemeData theme) {
    return Divider(
      height: 1,
      indent: 60,
      endIndent: 20,
      color: theme.dividerColor.withValues(alpha: 0.08),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 22, color: color),
    );
  }

  Widget _premiumField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool enabled = true,
  }) {
    // Determine color based on enabled state
    final color = enabled ? AppColors.primaryBlue : Colors.grey;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: TextFormField(
        controller: ctrl,
        enabled: enabled,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: enabled ? null : Colors.grey),
          prefixIcon: Icon(icon, color: color),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  void _showChangePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña actual',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Nueva contraseña',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.vpn_key_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmar contraseña',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.check_circle_outline),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authStateProvider.notifier).logout();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
