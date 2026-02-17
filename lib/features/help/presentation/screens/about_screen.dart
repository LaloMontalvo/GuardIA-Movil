import 'package:flutter/material.dart';

/// Pantalla Acerca de — versión, términos, créditos
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Logo y versión
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset('assets/GuardIA.png', fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 16),
                Text('GuardIA', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Vigilancia Comunitaria Inteligente', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Versión 1.0.0 (Build 1)', style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontSize: 13)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Info
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.update),
                  title: const Text('Versión'),
                  trailing: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.build),
                  title: const Text('Build'),
                  trailing: const Text('2026.02.12'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.flutter_dash),
                  title: const Text('Flutter'),
                  trailing: const Text('3.27.x'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Legal
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Términos y Condiciones'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showInfo(context, 'Términos y Condiciones'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Política de Privacidad'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showInfo(context, 'Política de Privacidad'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.source_outlined),
                  title: const Text('Licencias de código abierto'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showLicensePage(
                      context: context,
                      applicationName: 'GuardIA',
                      applicationVersion: '1.0.0',
                      applicationIcon: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.shield, size: 48, color: theme.colorScheme.primary),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Créditos
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Créditos', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Desarrollado con ❤️ por el equipo GuardIA'),
                  const SizedBox(height: 4),
                  Text('© 2026 GuardIA. Todos los derechos reservados.', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showInfo(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abriendo $title...')),
    );
  }
}
