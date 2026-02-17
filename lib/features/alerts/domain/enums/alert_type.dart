import 'package:flutter/material.dart';

/// Tipos de alerta
enum AlertType {
  motion,
  intrusion,
  fire,
  tamper,
  soundDetection;

  String get displayName {
    switch (this) {
      case AlertType.motion:
        return 'Movimiento';
      case AlertType.intrusion:
        return 'Intrusión';
      case AlertType.fire:
        return 'Fuego';
      case AlertType.tamper:
        return 'Sabotaje';
      case AlertType.soundDetection:
        return 'Detección de sonido';
    }
  }

  IconData get icon {
    switch (this) {
      case AlertType.motion:
        return Icons.directions_walk;
      case AlertType.intrusion:
        return Icons.warning;
      case AlertType.fire:
        return Icons.local_fire_department;
      case AlertType.tamper:
        return Icons.front_hand;
      case AlertType.soundDetection:
        return Icons.volume_up;
    }
  }

  static AlertType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'motion':
        return AlertType.motion;
      case 'intrusion':
        return AlertType.intrusion;
      case 'fire':
        return AlertType.fire;
      case 'tamper':
        return AlertType.tamper;
      case 'sounddetection':
        return AlertType.soundDetection;
      default:
        return AlertType.motion;
    }
  }
}
