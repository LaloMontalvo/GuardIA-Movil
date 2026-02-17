import 'package:flutter/material.dart';

/// Pantalla de panel de administración
class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats
          Row(
            children: [
              Expanded(child: _AdminStat(icon: Icons.people, label: 'Usuarios', value: '12', color: Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _AdminStat(icon: Icons.videocam, label: 'Cámaras', value: '7', color: Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _AdminStat(icon: Icons.warning, label: 'Alertas hoy', value: '5', color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 24),

          _SectionTitle(title: 'Gestión'),
          Card(
            child: Column(
              children: [
                _AdminTile(icon: Icons.people_outline, title: 'Usuarios', subtitle: '12 registrados', onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserManagementScreen()));
                }),
                const Divider(height: 1),
                _AdminTile(icon: Icons.videocam_outlined, title: 'Cámaras', subtitle: '7 configuradas', onTap: () {
                  Navigator.of(context).pushNamed('/cameras');
                }),
                const Divider(height: 1),
                _AdminTile(icon: Icons.map_outlined, title: 'Zonas', subtitle: '4 zonas definidas', onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ZoneManagementScreen()));
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _SectionTitle(title: 'Reportes y Bitácora'),
          Card(
            child: Column(
              children: [
                _AdminTile(icon: Icons.assessment_outlined, title: 'Reportes', subtitle: 'Estadísticas del sistema', onTap: () {
                  Navigator.of(context).pushNamed('/reports');
                }),
                const Divider(height: 1),
                _AdminTile(icon: Icons.history, title: 'Bitácora de Actividad', subtitle: 'Registro de acciones', onTap: () {
                  Navigator.of(context).pushNamed('/activity-log');
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _SectionTitle(title: 'Configuración'),
          Card(
            child: Column(
              children: [
                _AdminTile(icon: Icons.security_outlined, title: 'Seguridad', subtitle: 'Políticas y contraseñas', onTap: () {}),
                const Divider(height: 1),
                _AdminTile(icon: Icons.cloud_outlined, title: 'Almacenamiento', subtitle: '45% usado (120GB de 256GB)', onTap: () {}),
                const Divider(height: 1),
                _AdminTile(icon: Icons.notifications_outlined, title: 'Notificaciones globales', subtitle: 'Configurar alertas para todos', onTap: () {}),
                const Divider(height: 1),
                _AdminTile(icon: Icons.backup_outlined, title: 'Respaldos', subtitle: 'Último: hace 2 horas', onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _AdminStat({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _AdminTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// Pantalla de gestión de usuarios
class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = [
      _MockUser(name: 'Admin GuardIA', email: 'admin@guardia.com', role: 'Administrador', isActive: true),
      _MockUser(name: 'María López', email: 'maria@guardia.com', role: 'Operador', isActive: true),
      _MockUser(name: 'Carlos Ruiz', email: 'carlos@guardia.com', role: 'Usuario', isActive: true),
      _MockUser(name: 'Ana García', email: 'ana@guardia.com', role: 'Usuario', isActive: false),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: user.isActive ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                child: Text(user.name[0], style: TextStyle(color: user.isActive ? Colors.green : Colors.grey, fontWeight: FontWeight.bold)),
              ),
              title: Text(user.name),
              subtitle: Text('${user.email}\n${user.role}'),
              isThreeLine: true,
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'role', child: Text('Cambiar rol')),
                  PopupMenuItem(value: 'toggle', child: Text(user.isActive ? 'Desactivar' : 'Activar')),
                  const PopupMenuItem(value: 'reset', child: Text('Reset contraseña')),
                ],
                onSelected: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$value (simulado)')));
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Crear usuario (simulado)')));
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

class _MockUser {
  final String name, email, role;
  final bool isActive;
  _MockUser({required this.name, required this.email, required this.role, required this.isActive});
}

/// Pantalla de gestión de zonas
class ZoneManagementScreen extends StatelessWidget {
  const ZoneManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final zones = [
      _MockZone(name: 'Zona A', cameras: 3, description: 'Entrada y recepción'),
      _MockZone(name: 'Zona B', cameras: 2, description: 'Estacionamiento'),
      _MockZone(name: 'Zona C', cameras: 1, description: 'Área de servicio'),
      _MockZone(name: 'Zona D', cameras: 1, description: 'Patio trasero'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Zonas')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: zones.length,
        itemBuilder: (context, index) {
          final zone = zones[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.15),
                child: const Icon(Icons.map, color: Colors.blue),
              ),
              title: Text(zone.name),
              subtitle: Text('${zone.cameras} cámaras · ${zone.description}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Editar ${zone.name} (simulado)')));
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Crear zona (simulado)')));
        },
        child: const Icon(Icons.add_location),
      ),
    );
  }
}

class _MockZone {
  final String name, description;
  final int cameras;
  _MockZone({required this.name, required this.cameras, required this.description});
}
