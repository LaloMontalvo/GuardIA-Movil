import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Estados de una alerta
enum AlertStatus {
  pending,
  reviewing,
  confirmed,
  falsePositive,
  resolved;

  String get displayName {
    switch (this) {
      case AlertStatus.pending:
        return 'Pendiente';
      case AlertStatus.reviewing:
        return 'En revisión';
      case AlertStatus.confirmed:
        return 'Confirmada';
      case AlertStatus.falsePositive:
        return 'Falso positivo';
      case AlertStatus.resolved:
        return 'Resuelta';
    }
  }

  Color get color {
    switch (this) {
      case AlertStatus.pending:
        return AppColors.warningYellow;
      case AlertStatus.reviewing:
        return AppColors.infoBlue;
      case AlertStatus.confirmed:
        return AppColors.errorRed;
      case AlertStatus.falsePositive:
        return AppColors.grey500;
      case AlertStatus.resolved:
        return AppColors.successGreen;
    }
  }

  static AlertStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return AlertStatus.pending;
      case 'reviewing':
        return AlertStatus.reviewing;
      case 'confirmed':
        return AlertStatus.confirmed;
      case 'falsepositive':
        return AlertStatus.falsePositive;
      case 'resolved':
        return AlertStatus.resolved;
      default:
        return AlertStatus.pending;
    }
  }
}
