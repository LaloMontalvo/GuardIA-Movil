import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Modal para solicitar permiso de ubicación con explicación
class LocationPermissionModal extends StatelessWidget {
  const LocationPermissionModal({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LocationPermissionModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentCyan.withValues(alpha: 0.15),
                    AppColors.primaryBlue.withValues(alpha: 0.08),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: 40,
                color: isDark ? AppColors.accentCyan : AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Permiso de ubicación',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'GuardIA necesita acceso a tu ubicación para:\n\n'
              '• Registrar la ubicación de tus reportes\n'
              '• Compartir tu posición en tiempo real durante emergencias\n'
              '• Mostrarte incidentes cercanos a tu zona',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Primary button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.settings_rounded, size: 18),
                label: const Text('Abrir ajustes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Secondary button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Ahora no',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
