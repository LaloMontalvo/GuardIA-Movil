import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/confirm_dialog.dart';

/// Pantalla de Seguridad — contraseña, PIN/biometría, sesiones
class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool _biometricEnabled = false;
  bool _pinEnabled = false;

  // Mock sessions data
  final List<Map<String, dynamic>> _sessions = [
    {
      'id': 'ses_1',
      'device': 'CRT LX3 (este dispositivo)',
      'lastActive': 'Ahora',
      'isCurrent': true,
      'icon': Icons.phone_android,
    },
    {
      'id': 'ses_2',
      'device': 'Chrome — Windows',
      'lastActive': 'Hace 3 horas',
      'isCurrent': false,
      'icon': Icons.laptop,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Seguridad')),
      body: ListView(
        children: [
          // Contraseña
          _SectionTitle(title: 'Contraseña'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Cambiar contraseña'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangePasswordDialog(context),
          ),

          const Divider(height: 24),

          // Bloqueo de app
          _SectionTitle(title: 'Bloqueo de aplicación'),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Desbloqueo biométrico'),
            subtitle: const Text('Usar huella dactilar o reconocimiento facial'),
            value: _biometricEnabled,
            onChanged: (value) {
              setState(() => _biometricEnabled = value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(value ? 'Biometría activada' : 'Biometría desactivada')),
              );
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.pin_outlined),
            title: const Text('PIN de acceso'),
            subtitle: const Text('Código de 4 dígitos para abrir la app'),
            value: _pinEnabled,
            onChanged: (value) {
              if (value) {
                _showSetPinDialog(context);
              } else {
                setState(() => _pinEnabled = false);
              }
            },
          ),

          const Divider(height: 24),

          // Sesiones activas
          _SectionTitle(title: 'Dispositivos y sesiones'),
          ..._sessions.map((session) => ListTile(
                leading: Icon(session['icon'] as IconData),
                title: Text(session['device'] as String),
                subtitle: Text(session['lastActive'] as String),
                trailing: session['isCurrent'] == true
                    ? Chip(
                        label: const Text('Actual', style: TextStyle(fontSize: 11)),
                        backgroundColor: theme.colorScheme.primaryContainer,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      )
                    : TextButton(
                        onPressed: () async {
                          final confirmed = await ConfirmDialog.show(
                            context,
                            title: 'Cerrar sesión',
                            message: '¿Cerrar sesión en "${session['device']}"?',
                            confirmText: 'Cerrar',
                            isDangerous: true,
                          );
                          if (confirmed == true) {
                            setState(() => _sessions.removeWhere((s) => s['id'] == session['id']));
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sesión cerrada')),
                              );
                            }
                          }
                        },
                        child: Text('Cerrar', style: TextStyle(color: theme.colorScheme.error)),
                      ),
              )),

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await ConfirmDialog.show(
                  context,
                  title: 'Cerrar todas las sesiones',
                  message: '¿Cerrar sesión en todos los dispositivos excepto este?',
                  confirmText: 'Cerrar todas',
                  isDangerous: true,
                );
                if (confirmed == true) {
                  setState(() => _sessions.removeWhere((s) => s['isCurrent'] != true));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Todas las sesiones remotas cerradas')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar todas las sesiones'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña actual', prefixIcon: Icon(Icons.lock)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nueva contraseña', prefixIcon: Icon(Icons.lock_outline)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmar contraseña', prefixIcon: Icon(Icons.lock_outline)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contraseña actualizada correctamente')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showSetPinDialog(BuildContext context) {
    final pinCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Establecer PIN'),
        content: TextField(
          controller: pinCtrl,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'PIN de 4 dígitos', prefixIcon: Icon(Icons.pin)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (pinCtrl.text.length == 4) {
                setState(() => _pinEnabled = true);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN establecido')),
                );
              }
            },
            child: const Text('Establecer'),
          ),
        ],
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
