import 'package:flutter/material.dart';

/// Pantalla de bitácora de actividad
class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  final _logs = [
    _MockLog(user: 'Admin GuardIA', action: 'Cerró alerta', detail: 'Alerta #5 marcada como resuelta', time: '14:30', icon: Icons.check_circle, color: Colors.green),
    _MockLog(user: 'Admin GuardIA', action: 'Inicio de sesión', detail: 'Dispositivo: iPhone 15', time: '14:15', icon: Icons.login, color: Colors.blue),
    _MockLog(user: 'Usuario Demo', action: 'Exportó grabación', detail: 'Cámara Entrada Principal - 5 min', time: '13:45', icon: Icons.download, color: Colors.orange),
    _MockLog(user: 'Sistema', action: 'Cámara desconectada', detail: 'Pasillo Norte se desconectó', time: '12:30', icon: Icons.videocam_off, color: Colors.red),
    _MockLog(user: 'Admin GuardIA', action: 'Editó cámara', detail: 'Cambio zona en Estacionamiento', time: '11:00', icon: Icons.edit, color: Colors.purple),
    _MockLog(user: 'Sistema', action: 'Alerta generada', detail: 'Movimiento en Patio Trasero', time: '10:15', icon: Icons.warning, color: Colors.orange),
    _MockLog(user: 'Usuario Demo', action: 'Cierre de sesión', detail: 'Sesión web cerrada', time: '09:00', icon: Icons.logout, color: Colors.grey),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitácora de Actividad'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () => _showFilters()),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exportando bitácora... (simulado)')),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _logs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          final log = _logs[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: log.color.withOpacity(0.15),
                child: Icon(log.icon, color: log.color, size: 20),
              ),
              title: Text(log.action, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.detail),
                  const SizedBox(height: 2),
                  Text('${log.user} · ${log.time}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtros', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Text('Usuario'),
            Wrap(spacing: 8, children: ['Todos', 'Admin', 'Usuarios', 'Sistema'].map((f) => FilterChip(label: Text(f), selected: f == 'Todos', onSelected: (_) {})).toList()),
            const SizedBox(height: 12),
            const Text('Acción'),
            Wrap(spacing: 8, children: ['Todas', 'Login', 'Alertas', 'Cámaras', 'Exportar'].map((f) => FilterChip(label: Text(f), selected: f == 'Todas', onSelected: (_) {})).toList()),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Aplicar'))),
          ],
        ),
      ),
    );
  }
}

class _MockLog {
  final String user, action, detail, time;
  final IconData icon;
  final Color color;
  _MockLog({required this.user, required this.action, required this.detail, required this.time, required this.icon, required this.color});
}

/// Pantalla de reportes rápidos
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'pdf', child: Text('Exportar PDF')),
              const PopupMenuItem(value: 'csv', child: Text('Exportar CSV')),
            ],
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Exportando $value... (simulado)')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Time range selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18),
                  const SizedBox(width: 8),
                  const Text('Última semana'),
                  const Spacer(),
                  TextButton(onPressed: () {}, child: const Text('Cambiar rango')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Alerts por día
          Text('Alertas por día', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _BarItem(label: 'Lun', value: 0.4, count: '5'),
                  _BarItem(label: 'Mar', value: 0.7, count: '8'),
                  _BarItem(label: 'Mié', value: 0.3, count: '4'),
                  _BarItem(label: 'Jue', value: 0.9, count: '12'),
                  _BarItem(label: 'Vie', value: 0.6, count: '7'),
                  _BarItem(label: 'Sáb', value: 0.2, count: '3'),
                  _BarItem(label: 'Dom', value: 0.1, count: '2'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Cámaras offline
          Text('Cámaras offline por período', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.videocam_off, color: Colors.white, size: 18)),
                  title: const Text('Pasillo Norte'),
                  subtitle: const Text('Offline: 12h total esta semana'),
                  trailing: const Text('3 eventos'),
                ),
                ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.orange.shade300, child: const Icon(Icons.videocam_off, color: Colors.white, size: 18)),
                  title: const Text('Salida Emergencia'),
                  subtitle: const Text('Offline: 4h total esta semana'),
                  trailing: const Text('1 evento'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Top zonas
          Text('Top zonas con más eventos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _ZoneItem(zone: 'Zona A', count: 18, percent: 0.45, color: Colors.blue),
                _ZoneItem(zone: 'Zona C', count: 12, percent: 0.3, color: Colors.orange),
                _ZoneItem(zone: 'Zona B', count: 10, percent: 0.25, color: Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final String label, count;
  final double value;
  const _BarItem({required this.label, required this.value, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(count, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Container(
          width: 28,
          height: 120 * value,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ZoneItem extends StatelessWidget {
  final String zone;
  final int count;
  final double percent;
  final Color color;
  const _ZoneItem({required this.zone, required this.count, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(zone)),
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: percent, backgroundColor: Colors.grey.shade200, color: color, minHeight: 12),
            ),
          ),
          const SizedBox(width: 12),
          Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
