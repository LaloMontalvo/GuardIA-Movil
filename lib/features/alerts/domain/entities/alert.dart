import '../enums/alert_type.dart';
import '../enums/alert_status.dart';
import '../enums/priority.dart';

/// Entidad de alerta
class Alert {
  final String id;
  final AlertType type;
  final Priority priority;
  final DateTime timestamp;
  final String cameraId;
  final String? cameraName;
  final String? thumbnailUrl;
  final AlertStatus status;
  final String? note;

  const Alert({
    required this.id,
    required this.type,
    required this.priority,
    required this.timestamp,
    required this.cameraId,
    this.cameraName,
    this.thumbnailUrl,
    required this.status,
    this.note,
  });

  bool get isPending => status == AlertStatus.pending;
  bool get isCritical => priority == Priority.critical;

  Alert copyWith({
    String? id,
    AlertType? type,
    Priority? priority,
    DateTime? timestamp,
    String? cameraId,
    String? cameraName,
    String? thumbnailUrl,
    AlertStatus? status,
    String? note,
  }) {
    return Alert(
      id: id ?? this.id,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      cameraId: cameraId ?? this.cameraId,
      cameraName: cameraName ?? this.cameraName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Alert &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Alert(id: $id, type: $type, priority: $priority, status: $status)';
  }
}
