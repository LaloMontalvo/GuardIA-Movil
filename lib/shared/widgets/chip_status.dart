import 'package:flutter/material.dart';

/// Chip de estado reutilizable con color e icono según estado
class ChipStatus extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool outlined;

  const ChipStatus({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.outlined = false,
  });

  /// Factory para estados comunes de reportes
  factory ChipStatus.enviado() => const ChipStatus(label: 'Enviado', color: Color(0xFF2196F3), icon: Icons.send_rounded);
  factory ChipStatus.enRevision() => const ChipStatus(label: 'En revisión', color: Color(0xFFFFA726), icon: Icons.hourglass_top_rounded);
  factory ChipStatus.cerrado() => const ChipStatus(label: 'Cerrado', color: Color(0xFF4CAF50), icon: Icons.check_circle_outline);
  factory ChipStatus.nuevo() => const ChipStatus(label: 'Nuevo', color: Color(0xFFE53935), icon: Icons.fiber_new_rounded);

  /// Factory para urgencias
  factory ChipStatus.urgenciaBaja() => const ChipStatus(label: 'Baja', color: Color(0xFF2196F3), icon: Icons.arrow_downward_rounded);
  factory ChipStatus.urgenciaMedia() => const ChipStatus(label: 'Media', color: Color(0xFFFFA726), icon: Icons.remove_rounded);
  factory ChipStatus.urgenciaAlta() => const ChipStatus(label: 'Alta', color: Color(0xFFE53935), icon: Icons.arrow_upward_rounded);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: outlined ? Border.all(color: color.withValues(alpha: 0.5)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
