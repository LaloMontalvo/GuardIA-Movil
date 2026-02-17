import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/app_providers.dart';

/// Wizard de permisos del dispositivo con permisos reales
class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen>
    with SingleTickerProviderStateMixin {
  final Map<String, bool> _permissions = {
    'notifications': false,
    'location': false,
    'storage': false,
  };

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _animController.forward();
    _checkExistingPermissions();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingPermissions() async {
    final notifStatus = await Permission.notification.status;
    final locationStatus = await Permission.location.status;

    if (mounted) {
      setState(() {
        _permissions['notifications'] = notifStatus.isGranted;
        _permissions['location'] = locationStatus.isGranted;
        // Storage permission check varies by Android version
        _permissions['storage'] = true; // Scoped storage in modern Android
      });
    }
  }

  Future<void> _requestPermission(String key) async {
    PermissionStatus status;

    switch (key) {
      case 'notifications':
        status = await Permission.notification.request();
        break;
      case 'location':
        status = await Permission.location.request();
        break;
      case 'storage':
        status = await Permission.storage.request();
        if (status.isPermanentlyDenied) {
          // For modern Android, photos permission
          status = await Permission.photos.request();
        }
        break;
      default:
        return;
    }

    if (mounted) {
      setState(() {
        _permissions[key] = status.isGranted;
      });

      if (status.isPermanentlyDenied) {
        _showSettingsDialog(key);
      }
    }
  }

  void _showSettingsDialog(String key) {
    final name = _getPermissionName(key);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Permiso de $name'),
        content: Text(
          'El permiso de $name fue denegado permanentemente. '
          'Puedes habilitarlo manualmente en la configuración del dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Más tarde'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Abrir Configuración'),
          ),
        ],
      ),
    );
  }

  String _getPermissionName(String key) {
    switch (key) {
      case 'notifications':
        return 'notificaciones';
      case 'location':
        return 'ubicación';
      case 'storage':
        return 'almacenamiento';
      default:
        return key;
    }
  }

  Future<void> _continue() async {
    final storage = ref.read(localStorageProvider);
    await storage.setPermissionsRequested(true);
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    48,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                // Header icon with gradient background
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.accentCyan],
                    ),
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Permisos necesarios',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Para que GuardIA funcione correctamente, necesitamos tu autorización:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 28),

                // Permission cards with staggered animation
                _PermissionCard(
                  icon: Icons.notifications_active_rounded,
                  title: 'Notificaciones',
                  description:
                      'Recibe alertas de seguridad en tiempo real, incluso con la app cerrada.',
                  isGranted: _permissions['notifications']!,
                  onRequest: () => _requestPermission('notifications'),
                  delay: 0,
                ),
                const SizedBox(height: 12),
                _PermissionCard(
                  icon: Icons.location_on_rounded,
                  title: 'Ubicación',
                  description:
                      'Necesaria para el mapa interactivo y el botón de pánico con geolocalización.',
                  isGranted: _permissions['location']!,
                  onRequest: () => _requestPermission('location'),
                  delay: 1,
                ),
                const SizedBox(height: 12),
                _PermissionCard(
                  icon: Icons.folder_rounded,
                  title: 'Almacenamiento',
                  description:
                      'Para guardar capturas y exportar grabaciones como evidencia.',
                  isGranted: _permissions['storage']!,
                  onRequest: () => _requestPermission('storage'),
                  delay: 2,
                ),

                const SizedBox(height: 24),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _continue,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Continuar',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: _continue,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue.withOpacity(0.7),
                    ),
                    child: const Text('Configurar después'),
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isGranted;
  final VoidCallback onRequest;
  final int delay;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.onRequest,
    required this.delay,
  });

  @override
  State<_PermissionCard> createState() => _PermissionCardState();
}

class _PermissionCardState extends State<_PermissionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    Future.delayed(Duration(milliseconds: 200 + (widget.delay * 150)), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Card(
          elevation: widget.isGranted ? 1 : 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: widget.isGranted
                ? const BorderSide(color: AppColors.successGreen, width: 1.5)
                : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.isGranted
                        ? AppColors.successGreen.withOpacity(0.15)
                        : AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.isGranted ? Icons.check_circle_rounded : widget.icon,
                    color: widget.isGranted
                        ? AppColors.successGreen
                        : AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.description,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                      ),
                    ],
                  ),
                ),
                if (!widget.isGranted)
                  TextButton(
                    onPressed: widget.onRequest,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                    ),
                    child: const Text('Permitir'),
                  )
                else
                  const Icon(Icons.check_rounded,
                      color: AppColors.successGreen),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
