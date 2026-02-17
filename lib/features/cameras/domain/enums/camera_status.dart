import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Estados de una cámara
enum CameraStatus {
  online,
  offline,
  maintenance;

  String get displayName {
    switch (this) {
      case CameraStatus.online:
        return 'En línea';
      case CameraStatus.offline:
        return 'Fuera de línea';
      case CameraStatus.maintenance:
        return 'Mantenimiento';
    }
  }

  Color get color {
    switch (this) {
      case CameraStatus.online:
        return AppColors.cameraOnline;
      case CameraStatus.offline:
        return AppColors.cameraOffline;
      case CameraStatus.maintenance:
        return AppColors.cameraMaintenance;
    }
  }

  IconData get icon {
    switch (this) {
      case CameraStatus.online:
        return Icons.videocam;
      case CameraStatus.offline:
        return Icons.videocam_off;
      case CameraStatus.maintenance:
        return Icons.construction;
    }
  }

  static CameraStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'online':
        return CameraStatus.online;
      case 'offline':
        return CameraStatus.offline;
      case 'maintenance':
        return CameraStatus.maintenance;
      default:
        return CameraStatus.offline;
    }
  }
}
