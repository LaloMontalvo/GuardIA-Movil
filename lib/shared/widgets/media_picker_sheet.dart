import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Resultado del media picker
enum MediaPickerResult { camera, gallery, video }

/// Bottom sheet para selección de medios: Cámara / Galería / Video corto
class MediaPickerSheet extends StatelessWidget {
  const MediaPickerSheet({super.key});

  static Future<MediaPickerResult?> show(BuildContext context) {
    return showModalBottomSheet<MediaPickerResult>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const MediaPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Agregar evidencia',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Selecciona el tipo de evidencia',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _MediaOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Cámara',
                      gradientColors: const [AppColors.primaryBlue, Color(0xFF8B5CF6)],
                      onTap: () => Navigator.pop(context, MediaPickerResult.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MediaOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Galería',
                      gradientColors: const [Color(0xFF10B981), Color(0xFF34D399)],
                      onTap: () => Navigator.pop(context, MediaPickerResult.gallery),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MediaOption(
                      icon: Icons.videocam_rounded,
                      label: 'Video',
                      gradientColors: const [Color(0xFFEF4444), Color(0xFFF97316)],
                      onTap: () => Navigator.pop(context, MediaPickerResult.video),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Máx. 5 archivos • 10 MB por archivo',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _MediaOption({
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
