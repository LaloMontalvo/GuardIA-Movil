import '../../domain/entities/alert.dart';
import '../../domain/enums/alert_type.dart';
import '../../domain/enums/alert_status.dart';
import '../../domain/enums/priority.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../../../core/network/mock_api_service.dart';

class AlertRepositoryImpl implements AlertRepository {
  final MockApiService _mockApiService;

  AlertRepositoryImpl(this._mockApiService);

  @override
  Future<List<Alert>> getAlerts() async {
    final response = await _mockApiService.getAlerts();
    final alertsJson = response.data['alerts'] as List;
    
    return alertsJson.map((json) => _alertFromJson(json)).toList();
  }

  @override
  Future<Alert> getAlertDetail(String id) async {
    final response = await _mockApiService.getAlertDetail(id);
    return _alertFromJson(response.data);
  }

  @override
  Future<Alert> updateAlert(String id, String status, String? note) async {
    final response = await _mockApiService.updateAlert(id, {
      'status': status,
      'note': note,
    });

    // En un caso real, retornaría la alerta actualizada completa
    // Por ahora, obtenemos el detalle actualizado
    return await getAlertDetail(id);
  }

  @override
  Future<List<Alert>> getAlertsByStatus(String status) async {
    final alerts = await getAlerts();
    return alerts.where((alert) => alert.status.name == status).toList();
  }

  Alert _alertFromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as String,
      type: AlertType.fromString(json['type'] as String),
      priority: Priority.fromString(json['priority'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      cameraId: json['cameraId'] as String,
      cameraName: json['cameraName'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      status: AlertStatus.fromString(json['status'] as String),
      note: json['note'] as String?,
    );
  }
}
