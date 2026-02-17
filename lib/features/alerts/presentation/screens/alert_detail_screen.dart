import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/alert_providers.dart';
import '../../domain/enums/alert_status.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../core/utils/date_formatter.dart';

/// Pantalla de detalle de alerta con acciones
class AlertDetailScreen extends ConsumerStatefulWidget {
  final String alertId;

  const AlertDetailScreen({super.key, required this.alertId});

  @override
  ConsumerState<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends ConsumerState<AlertDetailScreen> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alertAsync = ref.watch(alertDetailProvider(widget.alertId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de alerta'),
      ),
      body: alertAsync.when(
        data: (alert) {
          _noteController.text = alert.note ?? '';

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(alertDetailProvider(widget.alertId));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Imagen de evidencia
                if (alert.thumbnailUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: alert.thumbnailUrl!,
                      fit: BoxFit.cover,
                      height: 250,
                      placeholder: (context, url) => Container(
                        height: 250,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 250,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: const Icon(Icons.image_not_supported, size: 64),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Card de información
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              alert.type.icon,
                              color: alert.priority.color,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alert.type.displayName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    alert.priority.displayName,
                                    style: TextStyle(
                                      color: alert.priority.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          'Cámara',
                          alert.cameraName ?? 'Desconocida',
                          Icons.videocam_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Fecha y hora',
                          DateFormatter.formatDateTime(alert.timestamp),
                          Icons.access_time,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Estado',
                          alert.status.displayName,
                          Icons.flag_outlined,
                          color: alert.status.color,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Campo de notas
                Text(
                  'Notas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Agregar notas...',
                  ),
                ),
                const SizedBox(height: 16),

                // Acciones
                Text(
                  'Acciones',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _updateAlertStatus(
                            AlertStatus.confirmed,
                            'Alerta confirmada',
                          );
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Confirmar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _updateAlertStatus(
                            AlertStatus.falsePositive,
                            'Marcada como falso positivo',
                          );
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text('Falso positivo'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _updateAlertStatus(
                        AlertStatus.resolved,
                        'Alerta resuelta',
                      );
                    },
                    icon: const Icon(Icons.done_all),
                    label: const Text('Marcar como atendida'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingView(message: 'Cargando detalle...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(alertDetailProvider(widget.alertId));
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      {Color? color}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: color,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _updateAlertStatus(
      AlertStatus newStatus, String successMessage) async {
    try {
      await ref.read(alertRepositoryProvider).updateAlert(
            widget.alertId,
            newStatus.name,
            _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );

      // Invalidar provider para recargar
      ref.invalidate(alertDetailProvider(widget.alertId));
      ref.invalidate(alertsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
