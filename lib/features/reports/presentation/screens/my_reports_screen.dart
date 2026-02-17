import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pantalla "Mis Reportes" — historial de reportes/incidentes del vecino
class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  // Mock data local
  static final List<Map<String, dynamic>> _reports = [
    {
      'id': 'rpt_1',
      'folio': 'GIA-2026-0001',
      'type': 'Persona sospechosa',
      'typeIcon': Icons.person_search,
      'description': 'Persona sospechosa merodeando en el estacionamiento durante la noche',
      'status': 'reviewing',
      'statusLabel': 'En revisión',
      'statusColor': Colors.orange,
      'createdAt': '12 Feb 2026, 19:30',
      'cameraName': 'Cámara Estacionamiento',
      'location': 'Estacionamiento Nivel 1',
      'hasAttachments': true,
      'adminComment': null,
    },
    {
      'id': 'rpt_2',
      'folio': 'GIA-2026-0002',
      'type': 'Vandalismo',
      'typeIcon': Icons.broken_image,
      'description': 'Grafiti en la barda perimetral zona norte',
      'status': 'resolved',
      'statusLabel': 'Resuelto',
      'statusColor': Colors.green,
      'createdAt': '10 Feb 2026, 14:15',
      'cameraName': 'Cámara Pasillo Norte',
      'location': 'Barda norte',
      'hasAttachments': true,
      'adminComment': 'Se coordinó limpieza y se reforzó vigilancia en la zona',
    },
    {
      'id': 'rpt_3',
      'folio': 'GIA-2026-0003',
      'type': 'Ruido excesivo',
      'typeIcon': Icons.volume_up,
      'description': 'Ruido excesivo desde la casa 14 después de las 11pm',
      'status': 'sent',
      'statusLabel': 'Enviado',
      'statusColor': Colors.blue,
      'createdAt': '7 Feb 2026, 23:45',
      'cameraName': null,
      'location': 'Casa 14, Zona A',
      'hasAttachments': false,
      'adminComment': null,
    },
    {
      'id': 'rpt_4',
      'folio': 'GIA-2026-0004',
      'type': 'Otro',
      'typeIcon': Icons.report_outlined,
      'description': 'Luminaria de la calle principal no funciona',
      'status': 'closed',
      'statusLabel': 'Cerrado',
      'statusColor': Colors.grey,
      'createdAt': '2 Feb 2026, 10:00',
      'cameraName': null,
      'location': 'Calle Principal',
      'hasAttachments': false,
      'adminComment': 'Luminaria reparada el día 03/02',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis reportes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/create-incident'),
            tooltip: 'Nuevo reporte',
          ),
        ],
      ),
      body: _reports.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('No tienes reportes'),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => context.push('/create-incident'),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear reporte'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                return _ReportCard(report: report);
              },
            ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = report['statusColor'] as Color;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showReportDetail(context, report),
        child: Column(
          children: [
            // Header con folio y status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: theme.colorScheme.surfaceContainerHighest,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(report['folio'] as String,
                      style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(report['statusLabel'] as String,
                        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(report['typeIcon'] as IconData, size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(report['type'] as String,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(report['description'] as String,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(report['createdAt'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                      const Spacer(),
                      if (report['hasAttachments'] == true) ...[
                        Icon(Icons.attach_file, size: 14, color: Colors.grey),
                        const SizedBox(width: 2),
                        Text('Adjuntos', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                      ],
                    ],
                  ),
                  if (report['cameraName'] != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.videocam, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(report['cameraName'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDetail(BuildContext context, Map<String, dynamic> report) {
    final theme = Theme.of(context);
    final statusColor = report['statusColor'] as Color;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(report['folio'] as String, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(report['statusLabel'] as String,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _DetailRow(icon: Icons.category, label: 'Tipo', value: report['type'] as String),
              _DetailRow(icon: Icons.access_time, label: 'Fecha', value: report['createdAt'] as String),
              _DetailRow(icon: Icons.location_on, label: 'Ubicación', value: report['location'] as String),
              if (report['cameraName'] != null)
                _DetailRow(icon: Icons.videocam, label: 'Cámara', value: report['cameraName'] as String),

              const SizedBox(height: 16),
              Text('Descripción', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(report['description'] as String),

              if (report['adminComment'] != null) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.primaryContainer),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.admin_panel_settings, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('Respuesta del administrador',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(report['adminComment'] as String),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
