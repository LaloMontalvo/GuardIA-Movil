import 'package:flutter/material.dart';
import '../../../../shared/widgets/confirm_dialog.dart';

/// Pantalla de Almacenamiento — cache, descargas, limpiar
class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  double _cacheSizeMb = 24.3;
  double _downloadsSizeMb = 12.7;
  final double _totalUsedMb = 37.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Almacenamiento')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Resumen de uso
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.storage, size: 48, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    '${_totalUsedMb.toStringAsFixed(1)} MB',
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Espacio utilizado por GuardIA', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 16),

                  // Barra de uso
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _totalUsedMb / 200, // 200 MB límite hipotético
                      minHeight: 8,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_totalUsedMb.toStringAsFixed(1)} MB usados', style: theme.textTheme.bodySmall),
                      Text('200 MB límite', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Desglose
          Text('Desglose de uso', style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 8),

          _StorageItem(
            icon: Icons.image,
            title: 'Caché de miniaturas',
            subtitle: 'Previews de cámaras y alertas',
            sizeMb: _cacheSizeMb,
            color: Colors.blue,
            onClear: () async {
              final confirmed = await ConfirmDialog.show(
                context,
                title: 'Limpiar caché',
                message: '¿Eliminar las miniaturas en caché? Se descargarán nuevamente cuando las necesites.',
                confirmText: 'Limpiar',
              );
              if (confirmed == true) {
                setState(() {
                  _cacheSizeMb = 0;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Caché limpiado')),
                  );
                }
              }
            },
          ),

          _StorageItem(
            icon: Icons.download,
            title: 'Descargas',
            subtitle: 'Grabaciones y evidencias descargadas',
            sizeMb: _downloadsSizeMb,
            color: Colors.green,
            onClear: () async {
              final confirmed = await ConfirmDialog.show(
                context,
                title: 'Eliminar descargas',
                message: '¿Eliminar todas las grabaciones descargadas? No podrás verlas sin conexión.',
                confirmText: 'Eliminar',
                isDangerous: true,
              );
              if (confirmed == true) {
                setState(() {
                  _downloadsSizeMb = 0;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Descargas eliminadas')),
                  );
                }
              }
            },
          ),

          const SizedBox(height: 24),

          // Botón limpiar todo
          FilledButton.icon(
            onPressed: () async {
              final confirmed = await ConfirmDialog.show(
                context,
                title: 'Limpiar todo',
                message: '¿Eliminar caché y descargas? Se liberarán ${_totalUsedMb.toStringAsFixed(1)} MB.',
                confirmText: 'Limpiar todo',
                isDangerous: true,
                icon: Icons.delete_sweep,
              );
              if (confirmed == true) {
                setState(() {
                  _cacheSizeMb = 0;
                  _downloadsSizeMb = 0;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Almacenamiento limpiado')),
                  );
                }
              }
            },
            icon: const Icon(Icons.delete_sweep),
            label: const Text('Limpiar todo el almacenamiento'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StorageItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double sizeMb;
  final Color color;
  final VoidCallback onClear;

  const _StorageItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.sizeMb,
    required this.color,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${sizeMb.toStringAsFixed(1)} MB',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: sizeMb > 0 ? onClear : null,
            ),
          ],
        ),
      ),
    );
  }
}
