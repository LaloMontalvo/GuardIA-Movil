import '../../domain/entities/camera.dart';
import '../../domain/enums/camera_status.dart';
import '../../domain/repositories/camera_repository.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';

class CameraRepositoryImpl implements CameraRepository {
  final DioClient _dioClient;

  CameraRepositoryImpl(this._dioClient);

  @override
  Future<List<Camera>> getCameras() async {
    final response = await _dioClient.get(ApiConstants.cameras);
    final camerasJson = response.data['items'] as List;
    
    return camerasJson.map((json) => _cameraFromJson(json)).toList();
  }

  @override
  Future<Camera> getCameraDetail(String id) async {
    final response = await _dioClient.get(ApiConstants.cameraDetail(id));
    return _cameraFromJson(response.data['item'] ?? response.data);
  }

  @override
  Future<List<Camera>> searchCameras(String query) async {
    final cameras = await getCameras();
    
    return cameras.where((camera) {
      return camera.name.toLowerCase().contains(query.toLowerCase()) ||
             camera.location.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  @override
  Future<List<Camera>> getCamerasByStatus(String status) async {
    final cameras = await getCameras();
    return cameras.where((camera) => camera.status.name == status).toList();
  }

  Camera _cameraFromJson(Map<String, dynamic> json) {
    return Camera(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      status: CameraStatus.fromString(json['status'] as String),
      streamUrl: json['streamUrl'] as String?,
      zone: json['zone'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
