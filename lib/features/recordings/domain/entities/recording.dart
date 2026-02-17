/// Entidad de grabación
class Recording {
  final String id;
  final String cameraId;
  final String cameraName;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final String? thumbnailUrl;
  final String? videoUrl;
  final String? eventType;
  final int fileSizeMb;

  const Recording({
    required this.id,
    required this.cameraId,
    required this.cameraName,
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.thumbnailUrl,
    this.videoUrl,
    this.eventType,
    this.fileSizeMb = 0,
  });

  String get durationFormatted {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  Recording copyWith({
    String? id,
    String? cameraId,
    String? cameraName,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    String? thumbnailUrl,
    String? videoUrl,
    String? eventType,
    int? fileSizeMb,
  }) {
    return Recording(
      id: id ?? this.id,
      cameraId: cameraId ?? this.cameraId,
      cameraName: cameraName ?? this.cameraName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      eventType: eventType ?? this.eventType,
      fileSizeMb: fileSizeMb ?? this.fileSizeMb,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Recording && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
