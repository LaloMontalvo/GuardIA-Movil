import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/chip_status.dart';

/// Detalle de un reporte del operador
class OperatorReportDetailScreen extends StatelessWidget {
  final String reportId;
  const OperatorReportDetailScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Reporte', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (v) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Acción: $v')));
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Editar')),
              const PopupMenuItem(value: 'add', child: Text('Agregar información')),
              const PopupMenuItem(value: 'cancel', child: Text('Cancelar reporte')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Encabezado
          _buildHeader(theme, isDark),
          const SizedBox(height: 16),

          // Ubicación
          _buildLocationCard(theme, isDark),
          const SizedBox(height: 16),

          // Descripción
          _buildDescriptionCard(theme, isDark),
          const SizedBox(height: 16),

          // Evidencias
          _buildEvidenceGallery(theme, isDark),
          const SizedBox(height: 16),

          // Timeline de actividad
          _buildTimeline(theme, isDark),
          const SizedBox(height: 16),

          // Ubicación en vivo
          _buildLiveLocationCard(theme, isDark),
          const SizedBox(height: 24),

          // Botones de acción
          _buildActionButtons(context, theme, isDark),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.orange.withValues(alpha: 0.15),
                    Colors.orange.withValues(alpha: 0.05),
                  ]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_search_rounded, color: Colors.orange, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sospechoso',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Folio: $reportId',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ChipStatus.urgenciaMedia(),
              const SizedBox(width: 8),
              ChipStatus.enviado(),
              const Spacer(),
              Text('Hoy 14:30', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Text('Ubicación', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          // Map placeholder
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_rounded, size: 36, color: Colors.grey.shade400),
                  const SizedBox(height: 4),
                  Text('19.4326° N, 99.1332° W',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('Abrir en mapa', style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_rounded, color: isDark ? AppColors.accentCyan : AppColors.primaryBlue, size: 18),
              const SizedBox(width: 8),
              Text('Descripción', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Se observó a una persona sospechosa merodeando por la entrada principal del fraccionamiento. Vestía ropa oscura y revisaba vehículos estacionados. Se alejó al notar presencia.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceGallery(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library_rounded, color: Colors.deepPurple, size: 18),
              const SizedBox(width: 8),
              Text('Evidencias (2)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _EvidenceThumb(isDark: isDark, icon: Icons.camera_alt, label: 'Foto 1'),
              const SizedBox(width: 8),
              _EvidenceThumb(isDark: isDark, icon: Icons.camera_alt, label: 'Foto 2'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(ThemeData theme, bool isDark) {
    final steps = [
      _TimelineStep('Enviado', 'Hoy 14:30', Icons.send_rounded, true),
      _TimelineStep('Recibido por panel', 'Hoy 14:31', Icons.inbox_rounded, true),
      _TimelineStep('En revisión', 'Pendiente', Icons.hourglass_top_rounded, false),
      _TimelineStep('Cerrado', 'Pendiente', Icons.check_circle_outline, false),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline_rounded, color: Colors.teal, size: 18),
              const SizedBox(width: 8),
              Text('Actividad', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            final isLast = i == steps.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: step.completed
                            ? Colors.green.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(step.icon,
                          size: 14, color: step.completed ? Colors.green : Colors.grey),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 30,
                        color: step.completed
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.15),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(step.label,
                            style: TextStyle(
                                fontWeight: step.completed ? FontWeight.w600 : FontWeight.w400,
                                fontSize: 14,
                                color: step.completed ? null : Colors.grey)),
                        Text(step.time,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLiveLocationCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.my_location_rounded, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ubicación en vivo',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('Transmitiendo cada 30 segundos',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('ACTIVO',
                style: TextStyle(
                    color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme, bool isDark) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Información adicional agregada')),
              );
            },
            icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
            label: const Text('Agregar información'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Editando reporte...')),
              );
            },
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Editar reporte'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}

class _EvidenceThumb extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String label;
  const _EvidenceThumb({required this.isDark, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey.shade400, size: 28),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

class _TimelineStep {
  final String label, time;
  final IconData icon;
  final bool completed;
  const _TimelineStep(this.label, this.time, this.icon, this.completed);
}
