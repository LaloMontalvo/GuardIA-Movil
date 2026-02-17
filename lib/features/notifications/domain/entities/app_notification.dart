/// Entidad de notificación in-app
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type; // alert, camera, system, panic
  final DateTime timestamp;
  final bool isRead;
  final String? relatedId; // alertId, cameraId, etc.
  final String? imageUrl;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.relatedId,
    this.imageUrl,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    DateTime? timestamp,
    bool? isRead,
    String? relatedId,
    String? imageUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
