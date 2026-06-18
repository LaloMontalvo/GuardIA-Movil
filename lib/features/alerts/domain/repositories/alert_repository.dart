import '../entities/alert.dart';

/// Contrato del repositorio de alertas
abstract class AlertRepository {
  /// Obtener todas las alertas
  Future<List<Alert>> getAlerts();

  /// Obtener detalle de una alerta
  Future<Alert> getAlertDetail(String id);

  /// Actualizar el estado de una alerta
  Future<Alert> updateAlert(String id, String status, String? note);

  /// Filtrar alertas por status
  /// Crear un nuevo reporte
  Future<void> createReport({
    required String type,
    required String priority,
    required String description,
    required String locationJson,
    required String createdByUserId,
    required String role,
    required String status,
  });

  /// Enviar alerta de pánico
  Future<void> sendPanic();
}
