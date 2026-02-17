import 'dart:async';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

/// Servicio Mock que simula respuestas de la API
/// Permite desarrollo sin backend real
class MockApiService {
  // Simular delay de red
  Future<void> _delay() async {
    await Future.delayed(
      Duration(milliseconds: AppConstants.mockDelayMs),
    );
  }

  // ========== AUTH ==========

  Future<Response> login(String email, String password) async {
    await _delay();

    // Simular error si credenciales incorrectas
    if (email != 'user@guardia.com') {
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 401,
          data: {'message': 'Credenciales inválidas'},
        ),
      );
    }

    return Response(
      requestOptions: RequestOptions(path: '/auth/login'),
      statusCode: 200,
      data: {
        'accessToken': 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        'refreshToken': 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'id': 'user_1',
          'name': 'Usuario Demo',
          'email': email,
          'role': 'user',
        },
      },
    );
  }

  Future<Response> register(Map<String, dynamic> data) async {
    await _delay();

    return Response(
      requestOptions: RequestOptions(path: '/auth/register'),
      statusCode: 201,
      data: {
        'accessToken': 'mock_access_token_new',
        'refreshToken': 'mock_refresh_token_new',
        'user': {
          'id': 'user_new',
          'name': data['name'],
          'email': data['email'],
          'role': 'user',
        },
      },
    );
  }

  Future<Response> refreshToken(String refreshToken) async {
    await _delay();

    return Response(
      requestOptions: RequestOptions(path: '/auth/refresh'),
      statusCode: 200,
      data: {
        'accessToken': 'mock_access_token_refreshed',
        'refreshToken': 'mock_refresh_token_refreshed',
      },
    );
  }

  // ========== CAMERAS ==========

  Future<Response> getCameras() async {
    await _delay();

    return Response(
      requestOptions: RequestOptions(path: '/cameras'),
      statusCode: 200,
      data: {
        'cameras': [
          {
            'id': 'cam_1',
            'name': 'Cámara Entrada Principal',
            'location': 'Puerta de ingreso',
            'status': 'online',
            'streamUrl': 'rtsp://example.com/stream1',
            'zone': 'Zona A',
            'isFavorite': true,
          },
          {
            'id': 'cam_2',
            'name': 'Cámara Estacionamiento',
            'location': 'Estacionamiento Nivel 1',
            'status': 'online',
            'streamUrl': 'rtsp://example.com/stream2',
            'zone': 'Zona B',
            'isFavorite': false,
          },
          {
            'id': 'cam_3',
            'name': 'Cámara Pasillo Norte',
            'location': 'Pasillo piso 2',
            'status': 'offline',
            'streamUrl': null,
            'zone': 'Zona A',
            'isFavorite': false,
          },
          {
            'id': 'cam_4',
            'name': 'Cámara Patio Trasero',
            'location': 'Área de carga',
            'status': 'online',
            'streamUrl': 'rtsp://example.com/stream4',
            'zone': 'Zona C',
            'isFavorite': true,
          },
          {
            'id': 'cam_5',
            'name': 'Cámara Área Común',
            'location': 'Salón principal',
            'status': 'online',
            'streamUrl': 'rtsp://example.com/stream5',
            'zone': 'Zona A',
            'isFavorite': false,
          },
          {
            'id': 'cam_6',
            'name': 'Cámara Salida Emergencia',
            'location': 'Puerta sur',
            'status': 'maintenance',
            'streamUrl': null,
            'zone': 'Zona B',
            'isFavorite': false,
          },
          {
            'id': 'cam_7',
            'name': 'Cámara Recepción',
            'location': 'Hall de entrada',
            'status': 'online',
            'streamUrl': 'rtsp://example.com/stream7',
            'zone': 'Zona A',
            'isFavorite': true,
          },
        ],
      },
    );
  }

  Future<Response> getCameraDetail(String id) async {
    await _delay();

    return Response(
      requestOptions: RequestOptions(path: '/cameras/$id'),
      statusCode: 200,
      data: {
        'id': id,
        'name': 'Cámara Entrada Principal',
        'location': 'Puerta de ingreso',
        'status': 'online',
        'streamUrl': 'rtsp://example.com/stream1',
        'zone': 'Zona A',
        'isFavorite': true,
      },
    );
  }

  // ========== ALERTS ==========

  Future<Response> getAlerts() async {
    await _delay();

    final now = DateTime.now();

    return Response(
      requestOptions: RequestOptions(path: '/alerts'),
      statusCode: 200,
      data: {
        'alerts': [
          {
            'id': 'alert_1',
            'type': 'motion',
            'priority': 'high',
            'timestamp': now.subtract(const Duration(minutes: 5)).toIso8601String(),
            'cameraId': 'cam_1',
            'cameraName': 'Cámara Entrada Principal',
            'thumbnailUrl': 'https://picsum.photos/400/300?random=1',
            'status': 'pending',
            'note': null,
          },
          {
            'id': 'alert_2',
            'type': 'intrusion',
            'priority': 'critical',
            'timestamp': now.subtract(const Duration(minutes: 15)).toIso8601String(),
            'cameraId': 'cam_4',
            'cameraName': 'Cámara Patio Trasero',
            'thumbnailUrl': 'https://picsum.photos/400/300?random=2',
            'status': 'reviewing',
            'note': 'En proceso de verificación',
          },
          {
            'id': 'alert_3',
            'type': 'motion',
            'priority': 'medium',
            'timestamp': now.subtract(const Duration(hours: 1)).toIso8601String(),
            'cameraId': 'cam_2',
            'cameraName': 'Cámara Estacionamiento',
            'thumbnailUrl': 'https://picsum.photos/400/300?random=3',
            'status': 'confirmed',
            'note': 'Vehículo identificado',
          },
          {
            'id': 'alert_4',
            'type': 'soundDetection',
            'priority': 'low',
            'timestamp': now.subtract(const Duration(hours: 2)).toIso8601String(),
            'cameraId': 'cam_5',
            'cameraName': 'Cámara Área Común',
            'thumbnailUrl': 'https://picsum.photos/400/300?random=4',
            'status': 'falsePositive',
            'note': 'Ruido ambiental normal',
          },
          {
            'id': 'alert_5',
            'type': 'fire',
            'priority': 'critical',
            'timestamp': now.subtract(const Duration(hours: 5)).toIso8601String(),
            'cameraId': 'cam_7',
            'cameraName': 'Cámara Recepción',
            'thumbnailUrl': 'https://picsum.photos/400/300?random=5',
            'status': 'resolved',
            'note': 'Alarma activada, bomberos notificados',
          },
          {
            'id': 'alert_6',
            'type': 'tamper',
            'priority': 'high',
            'timestamp': now.subtract(const Duration(days: 1)).toIso8601String(),
            'cameraId': 'cam_3',
            'cameraName': 'Cámara Pasillo Norte',
            'thumbnailUrl': 'https://picsum.photos/400/300?random=6',
            'status': 'resolved',
            'note': 'Cámara reubicada',
          },
        ],
      },
    );
  }

  Future<Response> getAlertDetail(String id) async {
    await _delay();

    return Response(
      requestOptions: RequestOptions(path: '/alerts/$id'),
      statusCode: 200,
      data: {
        'id': id,
        'type': 'motion',
        'priority': 'high',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
        'cameraId': 'cam_1',
        'cameraName': 'Cámara Entrada Principal',
        'thumbnailUrl': 'https://picsum.photos/800/600?random=1',
        'status': 'pending',
        'note': null,
      },
    );
  }

  Future<Response> updateAlert(String id, Map<String, dynamic> data) async {
    await _delay();

    return Response(
      requestOptions: RequestOptions(path: '/alerts/$id'),
      statusCode: 200,
      data: {
        'id': id,
        'status': data['status'],
        'note': data['note'],
      },
    );
  }

  // ========== DASHBOARD ==========

  Future<Response> getDashboardStats() async {
    await _delay();

    return Response(
      requestOptions: RequestOptions(path: '/dashboard/stats'),
      statusCode: 200,
      data: {
        'camerasOnline': 5,
        'camerasOffline': 2,
        'alertsToday': 12,
        'alertsPending': 3,
        'alertsCritical': 1,
      },
    );
  }

  // ========== PANIC ==========

  Future<Response> sendPanic() async {
    await _delay();

    return Response(
      requestOptions: RequestOptions(path: '/panic'),
      statusCode: 200,
      data: {
        'message': 'Alerta de pánico enviada',
        'incidentId': 'panic_${DateTime.now().millisecondsSinceEpoch}',
      },
    );
  }

  // ========== USER REPORTS (Vecino) ==========

  Future<Response> getMyReports() async {
    await _delay();
    final now = DateTime.now();

    return Response(
      requestOptions: RequestOptions(path: '/reports/mine'),
      statusCode: 200,
      data: {
        'reports': [
          {
            'id': 'rpt_1',
            'folio': 'GIA-2026-0001',
            'type': 'suspicious_person',
            'description': 'Persona sospechosa merodeando en el estacionamiento durante la noche',
            'status': 'reviewing',
            'createdAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
            'cameraId': 'cam_2',
            'cameraName': 'Cámara Estacionamiento',
            'location': 'Estacionamiento Nivel 1',
            'hasAttachments': true,
            'adminComment': null,
          },
          {
            'id': 'rpt_2',
            'folio': 'GIA-2026-0002',
            'type': 'vandalism',
            'description': 'Grafiti en la barda perimetral zona norte',
            'status': 'resolved',
            'createdAt': now.subtract(const Duration(days: 2)).toIso8601String(),
            'cameraId': 'cam_3',
            'cameraName': 'Cámara Pasillo Norte',
            'location': 'Barda norte',
            'hasAttachments': true,
            'adminComment': 'Se coordinó limpieza y se reforzó vigilancia en la zona',
          },
          {
            'id': 'rpt_3',
            'folio': 'GIA-2026-0003',
            'type': 'noise',
            'description': 'Ruido excesivo desde la casa 14 después de las 11pm',
            'status': 'sent',
            'createdAt': now.subtract(const Duration(days: 5)).toIso8601String(),
            'cameraId': null,
            'cameraName': null,
            'location': 'Casa 14, Zona A',
            'hasAttachments': false,
            'adminComment': null,
          },
          {
            'id': 'rpt_4',
            'folio': 'GIA-2026-0004',
            'type': 'other',
            'description': 'Luminaria de la calle principal no funciona',
            'status': 'closed',
            'createdAt': now.subtract(const Duration(days: 10)).toIso8601String(),
            'cameraId': null,
            'cameraName': null,
            'location': 'Calle Principal',
            'hasAttachments': false,
            'adminComment': 'Luminaria reparada el día 03/02',
          },
        ],
      },
    );
  }

  Future<Response> createReport(Map<String, dynamic> data) async {
    await _delay();

    return Response(
      requestOptions: RequestOptions(path: '/reports'),
      statusCode: 201,
      data: {
        'id': 'rpt_${DateTime.now().millisecondsSinceEpoch}',
        'folio': 'GIA-2026-${(DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}',
        'status': 'sent',
        'message': 'Reporte enviado exitosamente',
      },
    );
  }

  // ========== SESSIONS (Seguridad) ==========

  Future<Response> getActiveSessions() async {
    await _delay();

    return Response(
      requestOptions: RequestOptions(path: '/auth/sessions'),
      statusCode: 200,
      data: {
        'sessions': [
          {
            'id': 'ses_1',
            'device': 'CRT LX3 (este dispositivo)',
            'lastActive': DateTime.now().toIso8601String(),
            'isCurrent': true,
            'location': 'Monterrey, MX',
          },
          {
            'id': 'ses_2',
            'device': 'Chrome - Windows',
            'lastActive': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
            'isCurrent': false,
            'location': 'Monterrey, MX',
          },
        ],
      },
    );
  }
}

