/// Entrada del log de actividad / bitácora
class ActivityLog {
  final String id;
  final String userId;
  final String userName;
  final String action; // login, logout, alert_closed, camera_added, etc.
  final String description;
  final DateTime timestamp;
  final String? targetType; // camera, alert, user, etc.
  final String? targetId;

  const ActivityLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.description,
    required this.timestamp,
    this.targetType,
    this.targetId,
  });
}
