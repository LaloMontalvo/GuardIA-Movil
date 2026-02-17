import 'package:flutter/material.dart';
import '../../domain/enums/camera_status.dart';

/// Widget de chip de estado de cámara
class CameraStatusChip extends StatelessWidget {
  final CameraStatus status;

  const CameraStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        status.icon,
        size: 16,
        color: status.color,
      ),
      label: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 11,
          color: status.color,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: status.color.withOpacity(0.1),
      side: BorderSide(color: status.color.withOpacity(0.3)),
    );
  }
}
