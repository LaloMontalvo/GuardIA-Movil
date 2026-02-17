import '../enums/camera_status.dart';

/// Entidad de cámara
class Camera {
  final String id;
  final String name;
  final String location;
  final CameraStatus status;
  final String? streamUrl;
  final String zone;
  final bool isFavorite;

  const Camera({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    this.streamUrl,
    required this.zone,
    this.isFavorite = false,
  });

  bool get isOnline => status == CameraStatus.online;
  bool get hasStream => streamUrl != null && streamUrl!.isNotEmpty;

  Camera copyWith({
    String? id,
    String? name,
    String? location,
    CameraStatus? status,
    String? streamUrl,
    String? zone,
    bool? isFavorite,
  }) {
    return Camera(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      status: status ?? this.status,
      streamUrl: streamUrl ?? this.streamUrl,
      zone: zone ?? this.zone,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Camera &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Camera(id: $id, name: $name, status: $status)';
  }
}
