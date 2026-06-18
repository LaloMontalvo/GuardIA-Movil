import '../../domain/entities/alert.dart';
import '../../domain/enums/alert_type.dart';
import '../../domain/enums/alert_status.dart';
import '../../domain/enums/priority.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';

class AlertRepositoryImpl implements AlertRepository {
  final DioClient _dioClient;

  AlertRepositoryImpl(this._dioClient);

  @override
  Future<List<Alert>> getAlerts() async {
    final response = await _dioClient.get(ApiConstants.alerts);
    final alertsJson = response.data['items'] as List;
    
    return alertsJson.map((json) => _alertFromJson(json)).toList();
  }

  @override
  Future<Alert> getAlertDetail(String id) async {
    final response = await _dioClient.get(ApiConstants.alertDetail(id));
    return _alertFromJson(response.data['item'] ?? response.data);
  }

  @override
  Future<Alert> updateAlert(String id, String status, String? note) async {
    await _dioClient.patch('${ApiConstants.alerts}/$id/workflow', data: {
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

  @override
  Future<void> createReport({
    required String type,
    required String priority,
    required String description,
    required String locationJson,
    required String createdByUserId,
    required String role,
    required String status,
  }) async {
    // Normalizar prioridad por si acaso, aunque la UI debería mandar 'baja', 'media' o 'alta'
    String mappedPriority = priority.toLowerCase().replaceAll('í', 'i');
    if (mappedPriority == 'critica' || mappedPriority == 'urgente') {
      mappedPriority = 'alta'; 
    }

    await _dioClient.post(ApiConstants.reports, data: {
      'created_by_user_id': createdByUserId,
      'role': role,
      'type': type,
      'priority': mappedPriority,
      'description': description.trim(),
      'status': status,
      'ubicacion': locationJson,
    });
  }

  @override
  Future<void> sendPanic() async {
    await _dioClient.post(ApiConstants.panic);
  }

  Alert _alertFromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id']?.toString() ?? '',
      type: AlertType.fromString(json['type']?.toString() ?? ''),
      priority: Priority.fromString(json['priority']?.toString() ?? ''),
      timestamp: json['timestamp'] != null ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now() : DateTime.now(),
      cameraId: json['cameraId']?.toString(),
      cameraName: json['cameraName']?.toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      status: AlertStatus.fromString(json['status']?.toString() ?? ''),
      note: json['note']?.toString(),
    );
  }
}
