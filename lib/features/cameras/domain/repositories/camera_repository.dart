import '../entities/camera.dart';

/// Contrato del repositorio de cámaras
abstract class CameraRepository {
  /// Obtener todas las cámaras
  Future<List<Camera>> getCameras();

  /// Obtener detalle de una cámara
  Future<Camera> getCameraDetail(String id);

  /// Buscar cámaras por nombre
  Future<List<Camera>> searchCameras(String query);

  /// Filtrar cámaras por status
  Future<List<Camera>> getCamerasByStatus(String status);
}
