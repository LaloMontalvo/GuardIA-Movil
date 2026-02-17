import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Niveles de prioridad
enum Priority {
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case Priority.low:
        return 'Baja';
      case Priority.medium:
        return 'Media';
      case Priority.high:
        return 'Alta';
      case Priority.critical:
        return 'Crítica';
    }
  }

  Color get color {
    switch (this) {
      case Priority.low:
        return AppColors.priorityLow;
      case Priority.medium:
        return AppColors.priorityMedium;
      case Priority.high:
        return AppColors.priorityHigh;
      case Priority.critical:
        return AppColors.priorityCritical;
    }
  }

  IconData get icon {
    switch (this) {
      case Priority.low:
        return Icons.arrow_downward;
      case Priority.medium:
        return Icons.remove;
      case Priority.high:
        return Icons.arrow_upward;
      case Priority.critical:
        return Icons.priority_high;
    }
  }

  static Priority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return Priority.low;
      case 'medium':
        return Priority.medium;
      case 'high':
        return Priority.high;
      case 'critical':
        return Priority.critical;
      default:
        return Priority.medium;
    }
  }
}
