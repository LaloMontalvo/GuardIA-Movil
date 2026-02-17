import 'package:flutter/material.dart';

/// Pantalla de gestión de evidencia / casos
class EvidenceScreen extends StatefulWidget {
  const EvidenceScreen({super.key});

  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> {
  final _cases = [
    _MockCase(id: '1', title: 'Intrusión Zona A - Feb 10', clipCount: 3, status: 'open', date: '10/02/2026'),
    _MockCase(id: '2', title: 'Persona sospechosa Estacionamiento', clipCount: 5, status: 'open', date: '09/02/2026'),
    _MockCase(id: '3', title: 'Incidente Patio Trasero', clipCount: 2, status: 'closed', date: '05/02/2026'),
    _MockCase(id: '4', title: 'Revisión cámaras Zona B', clipCount: 1, status: 'exported', date: '01/02/2026'),
  ];

  void _createCase() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Nuevo caso de evidencia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: controller, decoration: const InputDecoration(labelText: 'Nombre del caso')),
              const SizedBox(height: 8),
              const TextField(maxLines: 2, decoration: InputDecoration(labelText: 'Descripción (opcional)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Caso creado (simulado)'), backgroundColor: Colors.green),
                );
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidencias'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Casos abiertos', value: '2', color: Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Clips marcados', value: '11', color: Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Exportados', value: '1', color: Colors.green)),
            ],
          ),
          const SizedBox(height: 24),

          Text('Casos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          ..._cases.map((c) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: c.status == 'open' ? Colors.blue.withOpacity(0.15)
                    : c.status == 'closed' ? Colors.grey.withOpacity(0.15) : Colors.green.withOpacity(0.15),
                child: Icon(
                  c.status == 'exported' ? Icons.download_done : Icons.folder,
                  color: c.status == 'open' ? Colors.blue : c.status == 'closed' ? Colors.grey : Colors.green,
                ),
              ),
              title: Text(c.title),
              subtitle: Text('${c.clipCount} clips · ${c.date}'),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'add', child: Text('Agregar clips')),
                  const PopupMenuItem(value: 'export', child: Text('Exportar paquete')),
                  const PopupMenuItem(value: 'close', child: Text('Cerrar caso')),
                ],
                onSelected: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$value (simulado)')),
                  );
                },
              ),
            ),
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createCase,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo caso'),
      ),
    );
  }
}

class _MockCase {
  final String id, title, status, date;
  final int clipCount;
  _MockCase({required this.id, required this.title, required this.clipCount, required this.status, required this.date});
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
