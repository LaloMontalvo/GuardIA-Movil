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
  Future<List<Alert>> getAlertsByStatus(String status);
}
