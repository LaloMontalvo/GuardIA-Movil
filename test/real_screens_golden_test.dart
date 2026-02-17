import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:guardia_movil/app/theme/app_theme.dart';
import 'package:guardia_movil/core/di/app_providers.dart';
import 'package:guardia_movil/features/auth/domain/entities/role.dart';
import 'package:guardia_movil/features/auth/domain/entities/user.dart';
import 'package:guardia_movil/features/auth/presentation/providers/auth_providers.dart';
import 'package:guardia_movil/features/auth/presentation/screens/login_screen.dart';
import 'package:guardia_movil/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:guardia_movil/features/cameras/domain/entities/camera.dart';
import 'package:guardia_movil/features/cameras/domain/enums/camera_status.dart';
import 'package:guardia_movil/features/cameras/presentation/providers/camera_providers.dart';
import 'package:guardia_movil/features/cameras/presentation/screens/cameras_list_screen.dart';
import 'package:guardia_movil/features/cameras/presentation/screens/camera_detail_screen.dart';
import 'package:guardia_movil/features/cameras/presentation/screens/live_view_screen.dart';
import 'package:guardia_movil/features/alerts/domain/entities/alert.dart';
import 'package:guardia_movil/features/alerts/domain/enums/alert_status.dart';
import 'package:guardia_movil/features/alerts/domain/enums/alert_type.dart';
import 'package:guardia_movil/features/alerts/domain/enums/priority.dart';
import 'package:guardia_movil/features/alerts/presentation/providers/alert_providers.dart';
import 'package:guardia_movil/features/alerts/presentation/screens/alerts_list_screen.dart';
import 'package:guardia_movil/features/alerts/presentation/screens/alert_detail_screen.dart';
import 'package:guardia_movil/features/alerts/presentation/screens/create_incident_screen.dart';
import 'package:guardia_movil/features/alerts/presentation/screens/panic_screen.dart';
import 'package:guardia_movil/features/map/presentation/screens/map_screen.dart';
import 'package:guardia_movil/features/settings/presentation/screens/more_screen.dart';
import 'package:guardia_movil/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:guardia_movil/features/settings/presentation/screens/settings_screen.dart';
import 'package:guardia_movil/features/reports/presentation/screens/reports_screen.dart';
import 'package:guardia_movil/features/reports/presentation/screens/my_reports_screen.dart';

class _AuthStateNotifierMock extends StateNotifier<AuthState> {
  _AuthStateNotifierMock(AuthState state) : super(state);
}

class _FavoriteCamerasNotifierMock extends StateNotifier<List<String>> {
  _FavoriteCamerasNotifierMock(List<String> state) : super(state);
}

final _mockUser = User(
  id: 'u_1',
  name: 'Usuario Demo',
  email: 'user@guardia.com',
  role: Role.user,
  zone: 'Zona A',
);

final _mockCameras = <Camera>[
  const Camera(
    id: 'cam_1',
    name: 'Entrada Principal',
    location: 'Acceso Norte',
    status: CameraStatus.online,
    zone: 'Zona A',
    isFavorite: true,
  ),
  const Camera(
    id: 'cam_2',
    name: 'Pasillo Norte',
    location: 'Pasillo B',
    status: CameraStatus.offline,
    zone: 'Zona B',
  ),
  const Camera(
    id: 'cam_3',
    name: 'Estacionamiento',
    location: 'Nivel 1',
    status: CameraStatus.online,
    zone: 'Zona A',
  ),
];

final _mockAlerts = <Alert>[
  Alert(
    id: 'al_1',
    type: AlertType.intrusion,
    priority: Priority.critical,
    timestamp: DateTime(2026, 2, 16, 14, 30),
    cameraId: 'cam_1',
    cameraName: 'Entrada Principal',
    status: AlertStatus.pending,
    note: 'Posible intrusión en acceso principal',
  ),
  Alert(
    id: 'al_2',
    type: AlertType.motion,
    priority: Priority.medium,
    timestamp: DateTime(2026, 2, 16, 10, 0),
    cameraId: 'cam_3',
    cameraName: 'Estacionamiento',
    status: AlertStatus.reviewing,
  ),
];

List<Override> _overrides() {
  return [
    authStateProvider.overrideWith((ref) => _AuthStateNotifierMock(AuthState(user: _mockUser))),
    camerasProvider.overrideWith((ref) async => _mockCameras),
    cameraDetailProvider.overrideWith((ref, id) async {
      return _mockCameras.firstWhere(
        (c) => c.id == id,
        orElse: () => _mockCameras.first,
      );
    }),
    alertsProvider.overrideWith((ref) async => _mockAlerts),
    alertDetailProvider.overrideWith((ref, id) async {
      return _mockAlerts.firstWhere(
        (a) => a.id == id,
        orElse: () => _mockAlerts.first,
      );
    }),
    favoriteCamerasProvider.overrideWith((ref) => _FavoriteCamerasNotifierMock(['cam_1'])),
    themeModeProvider.overrideWith((ref) => ThemeModeNotifier(ref.watch(localStorageProvider))),
  ];
}

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: _overrides(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: child,
    ),
  );
}

Future<void> _capture(WidgetTester tester, String fileName, Widget screen) async {
  await tester.binding.setSurfaceSize(const Size(430, 932));
  await tester.pumpWidget(_wrap(screen));
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(seconds: 2));
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens_real/$fileName.png'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('real_ui_login', (tester) async {
    await _capture(tester, '01_login', const LoginScreen());
  });

  testWidgets('real_ui_dashboard', (tester) async {
    await _capture(tester, '02_dashboard', const DashboardScreen());
  });

  testWidgets('real_ui_cameras_list', (tester) async {
    await _capture(tester, '03_cameras_list', const CamerasListScreen());
  });

  testWidgets('real_ui_camera_detail', (tester) async {
    await _capture(tester, '04_camera_detail', const CameraDetailScreen(cameraId: 'cam_1'));
  });

  testWidgets('real_ui_live_view', (tester) async {
    await _capture(tester, '05_live_view', const LiveViewScreen(cameraId: 'cam_1'));
  });

  testWidgets('real_ui_alerts_list', (tester) async {
    await _capture(tester, '06_alerts_list', const AlertsListScreen());
  });

  testWidgets('real_ui_alert_detail', (tester) async {
    await _capture(tester, '07_alert_detail', const AlertDetailScreen(alertId: 'al_1'));
  });

  testWidgets('real_ui_create_incident', (tester) async {
    await _capture(tester, '08_create_incident', const CreateIncidentScreen());
  });

  testWidgets('real_ui_map', (tester) async {
    await _capture(tester, '09_map', const MapScreen());
  });

  testWidgets('real_ui_more', (tester) async {
    await _capture(tester, '10_more', const MoreScreen());
  });

  testWidgets('real_ui_notifications', (tester) async {
    await _capture(tester, '11_notifications', const NotificationsScreen());
  });

  testWidgets('real_ui_settings', (tester) async {
    await _capture(tester, '12_settings', const SettingsScreen());
  });

  testWidgets('real_ui_reports', (tester) async {
    await _capture(tester, '13_reports', const ReportsScreen());
  });

  testWidgets('real_ui_my_reports', (tester) async {
    await _capture(tester, '14_my_reports', const MyReportsScreen());
  });

  testWidgets('real_ui_panic', (tester) async {
    await _capture(tester, '15_panic', const PanicScreen());
  });
}
