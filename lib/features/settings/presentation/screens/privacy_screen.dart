import 'package:flutter/material.dart';

/// Pantalla de Privacidad — permisos otorgados, política, términos
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacidad')),
      body: ListView(
        children: [
          // Permisos otorgados
          _SectionTitle(title: 'Permisos del dispositivo'),
          _PermissionTile(
            icon: Icons.notifications_active,
            title: 'Notificaciones',
            status: 'Permitido',
            isGranted: true,
          ),
          _PermissionTile(
            icon: Icons.location_on,
            title: 'Ubicación',
            status: 'Permitido',
            isGranted: true,
          ),
          _PermissionTile(
            icon: Icons.camera_alt,
            title: 'Cámara',
            status: 'No permitido',
            isGranted: false,
          ),
          _PermissionTile(
            icon: Icons.mic,
            title: 'Micrófono',
            status: 'No solicitado',
            isGranted: false,
          ),
          _PermissionTile(
            icon: Icons.folder,
            title: 'Almacenamiento',
            status: 'Permitido',
            isGranted: true,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abriendo ajustes del sistema...')),
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text('Administrar permisos del sistema'),
            ),
          ),

          const Divider(height: 32),

          // Documentos legales
          _SectionTitle(title: 'Documentos legales'),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Política de Privacidad'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _showLegalDocument(context, 'Política de Privacidad'),
          ),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: const Text('Términos y Condiciones'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _showLegalDocument(context, 'Términos y Condiciones'),
          ),
          ListTile(
            leading: const Icon(Icons.cookie_outlined),
            title: const Text('Aviso de Cookies'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _showLegalDocument(context, 'Aviso de Cookies'),
          ),

          const Divider(height: 32),

          // Datos del usuario
          _SectionTitle(title: 'Tus datos'),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Solicitar mis datos'),
            subtitle: const Text('Descarga una copia de tu información'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Solicitud enviada. Recibirás un correo.')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
            title: Text('Eliminar mi cuenta', style: TextStyle(color: theme.colorScheme.error)),
            subtitle: const Text('Esta acción es irreversible'),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('¿Eliminar cuenta?'),
                  content: const Text('Se eliminarán todos tus datos permanentemente. Esta acción no se puede deshacer.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Solicitud de eliminación enviada')),
                        );
                      },
                      child: Text('Eliminar', style: TextStyle(color: theme.colorScheme.error)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showLegalDocument(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (_, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Este es un documento de ejemplo para "$title".\n\n'
                  'GuardIA se compromete a proteger la privacidad de sus usuarios. '
                  'Los datos recopilados se utilizan exclusivamente para brindar el servicio de vigilancia comunitaria.\n\n'
                  'Información recopilada:\n'
                  '• Datos de registro (nombre, correo, teléfono)\n'
                  '• Ubicación (para mapas y reportes)\n'
                  '• Imágenes de cámaras (para monitoreo)\n\n'
                  'Tus derechos:\n'
                  '• Acceder a tus datos personales\n'
                  '• Rectificar información incorrecta\n'
                  '• Solicitar la eliminación de tus datos\n'
                  '• Revocar el consentimiento en cualquier momento\n\n'
                  'Última actualización: Febrero 2026',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String status;
  final bool isGranted;
  const _PermissionTile({required this.icon, required this.title, required this.status, required this.isGranted});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isGranted ? Colors.green : Colors.grey),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(status, style: TextStyle(color: isGranted ? Colors.green : Colors.grey, fontSize: 13)),
          const SizedBox(width: 4),
          Icon(isGranted ? Icons.check_circle : Icons.cancel, color: isGranted ? Colors.green : Colors.grey, size: 18),
        ],
      ),
    );
  }
}
