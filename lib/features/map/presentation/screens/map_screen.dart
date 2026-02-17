import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../app/theme/app_colors.dart';

/// Mapa interactivo con cámaras posicionadas alrededor de la ubicación real del usuario
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  bool _showCameras = true;
  bool _showAlerts = true;
  bool _showZones = false;
  bool _loading = true;
  String? _error;

  // Ubicación del usuario (se obtiene por GPS)
  LatLng _userLocation = const LatLng(25.6866, -100.3161); // Fallback: Monterrey
  List<_CameraMarker> _cameras = [];

  late AnimationController _fabCtrl;

  @override
  void initState() {
    super.initState();
    _fabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _getUserLocation();
  }

  @override
  void dispose() {
    _fabCtrl.dispose();
    super.dispose();
  }

  /// Obtiene la ubicación GPS del usuario y genera cámaras alrededor
  Future<void> _getUserLocation() async {
    setState(() { _loading = true; _error = null; });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() { _error = 'Servicio de ubicación desactivado'; _loading = false; });
        _generateCamerasAround(_userLocation);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() { _error = 'Permiso de ubicación denegado'; _loading = false; });
          _generateCamerasAround(_userLocation);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() { _error = 'Permiso de ubicación denegado permanentemente'; _loading = false; });
        _generateCamerasAround(_userLocation);
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() { _userLocation = LatLng(position.latitude, position.longitude); });
      _generateCamerasAround(_userLocation);
    } catch (e) {
      setState(() { _error = 'No se pudo obtener la ubicación'; });
      _generateCamerasAround(_userLocation);
    }
  }

  /// Genera 7 cámaras mock alrededor de una ubicación central
  void _generateCamerasAround(LatLng center) {
    final cameras = [
      _CameraMarker(id: 'cam_1', name: 'Entrada Principal', zone: 'Zona A',
        location: LatLng(center.latitude + 0.0012, center.longitude - 0.0008), isOnline: true, hasAlert: true),
      _CameraMarker(id: 'cam_2', name: 'Estacionamiento', zone: 'Zona A',
        location: LatLng(center.latitude + 0.0005, center.longitude + 0.0015), isOnline: true, hasAlert: false),
      _CameraMarker(id: 'cam_3', name: 'Pasillo Norte', zone: 'Zona B',
        location: LatLng(center.latitude - 0.0008, center.longitude - 0.0012), isOnline: false, hasAlert: false),
      _CameraMarker(id: 'cam_4', name: 'Patio Trasero', zone: 'Zona B',
        location: LatLng(center.latitude - 0.0005, center.longitude + 0.0020), isOnline: true, hasAlert: true),
      _CameraMarker(id: 'cam_5', name: 'Área Común', zone: 'Zona A',
        location: LatLng(center.latitude + 0.0003, center.longitude + 0.0003), isOnline: true, hasAlert: false),
      _CameraMarker(id: 'cam_6', name: 'Salida Emergencia', zone: 'Zona C',
        location: LatLng(center.latitude - 0.0015, center.longitude + 0.0005), isOnline: false, hasAlert: false),
      _CameraMarker(id: 'cam_7', name: 'Recepción', zone: 'Zona A',
        location: LatLng(center.latitude + 0.0008, center.longitude - 0.0002), isOnline: true, hasAlert: true),
    ];

    setState(() { _cameras = cameras; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onlineCount = _cameras.where((c) => c.isOnline && !c.hasAlert).length;
    final offlineCount = _cameras.where((c) => !c.isOnline).length;
    final alertCount = _cameras.where((c) => c.hasAlert).length;

    return Scaffold(
      body: _loading
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                      : [AppColors.primaryBlue.withOpacity(0.05), Colors.white],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryBlue, AppColors.accentCyan],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.map_rounded, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 24),
                    Text('Obteniendo tu ubicación...',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.primaryBlue),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 120,
                      child: LinearProgressIndicator(
                        borderRadius: BorderRadius.circular(4),
                        color: AppColors.primaryBlue,
                        backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                // ── Mapa ──
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _userLocation,
                    initialZoom: 16.0,
                    minZoom: 10,
                    maxZoom: 19,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.guardia.movil',
                    ),
                    if (_showZones) PolygonLayer(polygons: _buildZonePolygons()),
                    // User marker
                    MarkerLayer(markers: [
                      Marker(
                        point: _userLocation, width: 30, height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(color: AppColors.primaryBlue.withOpacity(0.4), blurRadius: 12, spreadRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ]),
                    MarkerLayer(markers: _buildCameraMarkers()),
                  ],
                ),

                // ── Top bar glassmorphic ──
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 16, right: 16, bottom: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          (isDark ? const Color(0xFF1A1A2E) : Colors.white).withOpacity(0.95),
                          (isDark ? const Color(0xFF1A1A2E) : Colors.white).withOpacity(0.0),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        // Title
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white.withOpacity(0.1) : Colors.white),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.map_rounded, size: 20, color: isDark ? Colors.white : AppColors.primaryBlue),
                              const SizedBox(width: 8),
                              Text('Mapa', style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17,
                                color: isDark ? Colors.white : Colors.black87,
                              )),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Layers btn
                        _glassButton(
                          isDark: isDark,
                          icon: Icons.layers_rounded,
                          onTap: _showLayersSheet,
                        ),
                        const SizedBox(width: 8),
                        // My location btn
                        _glassButton(
                          isDark: isDark,
                          icon: Icons.my_location_rounded,
                          onTap: () => _mapController.move(_userLocation, 16.0),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Error banner ──
                if (_error != null)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 64,
                    left: 16, right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 10),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(_error!, style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w500))),
                          TextButton(
                            onPressed: _getUserLocation,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: const Text('Reintentar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Premium legend bar ──
                Positioned(
                  bottom: 16, left: 16, right: 16,
                  child: FadeTransition(
                    opacity: _fabCtrl,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A2E).withOpacity(0.92) : Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _legendChip(Icons.videocam_rounded, Colors.green, 'Online', onlineCount),
                          _legendDot(),
                          _legendChip(Icons.videocam_off_rounded, Colors.grey, 'Offline', offlineCount),
                          _legendDot(),
                          _legendChip(Icons.warning_rounded, Colors.red, 'Alertas', alertCount),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ── Glass button ──
  Widget _glassButton({required bool isDark, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(icon, size: 22, color: isDark ? Colors.white : AppColors.primaryBlue),
      ),
    );
  }

  // ── Legend chip ──
  Widget _legendChip(IconData icon, Color color, String label, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$count', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ],
        ),
      ],
    );
  }

  Widget _legendDot() => Container(
    width: 4, height: 4,
    decoration: BoxDecoration(color: Colors.grey.shade400, shape: BoxShape.circle),
  );

  // ── Camera markers ──
  List<Marker> _buildCameraMarkers() {
    return _cameras.where((c) {
      if (!_showCameras && !c.hasAlert) return false;
      if (!_showAlerts && c.hasAlert && !_showCameras) return false;
      return true;
    }).map((cam) {
      final color = cam.hasAlert ? Colors.red : cam.isOnline ? Colors.green : Colors.grey;
      final icon = cam.hasAlert ? Icons.warning_rounded : Icons.videocam_rounded;

      return Marker(
        point: cam.location, width: 48, height: 48,
        child: GestureDetector(
          onTap: () => _showMarkerDetail(context, cam),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.7)],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, spreadRadius: 2),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      );
    }).toList();
  }

  // ── Zone polygons ──
  List<Polygon> _buildZonePolygons() {
    final c = _userLocation;
    return [
      Polygon(
        points: [
          LatLng(c.latitude + 0.0018, c.longitude - 0.0020),
          LatLng(c.latitude + 0.0018, c.longitude + 0.0005),
          LatLng(c.latitude, c.longitude + 0.0005),
          LatLng(c.latitude, c.longitude - 0.0020),
        ],
        color: Colors.blue.withOpacity(0.1),
        borderColor: Colors.blue.withOpacity(0.5),
        borderStrokeWidth: 2,
        label: 'Zona A',
        labelStyle: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      Polygon(
        points: [
          LatLng(c.latitude, c.longitude - 0.0020),
          LatLng(c.latitude, c.longitude + 0.0025),
          LatLng(c.latitude - 0.0020, c.longitude + 0.0025),
          LatLng(c.latitude - 0.0020, c.longitude - 0.0020),
        ],
        color: Colors.orange.withOpacity(0.1),
        borderColor: Colors.orange.withOpacity(0.5),
        borderStrokeWidth: 2,
        label: 'Zona B',
        labelStyle: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    ];
  }

  // ── Premium marker detail bottom sheet ──
  void _showMarkerDetail(BuildContext context, _CameraMarker cam) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = cam.hasAlert ? Colors.red : cam.isOnline ? Colors.green : Colors.grey;
    final statusText = cam.hasAlert ? 'Alerta activa' : cam.isOnline ? 'En línea' : 'Fuera de línea';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E30) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, -4)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [statusColor, statusColor.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: statusColor.withOpacity(0.3), blurRadius: 10),
                    ],
                  ),
                  child: Icon(
                    cam.hasAlert ? Icons.warning_rounded : Icons.videocam_rounded,
                    color: Colors.white, size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cam.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(statusText, style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w500)),
                          Text(' · ${cam.zone}', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Alert banner
            if (cam.hasAlert) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.warning_rounded, color: Colors.red, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Alerta activa en esta cámara',
                        style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            // Actions
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primaryBlue, AppColors.accentCyan]),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.pop(ctx);
                          context.push('/camera/${cam.id}/live');
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                              SizedBox(width: 8),
                              Text('Ver en vivo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push('/camera/${cam.id}');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        child: Icon(Icons.info_outline_rounded, color: isDark ? AppColors.accentCyan : AppColors.primaryBlue, size: 22),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Premium layers bottom sheet ──
  void _showLayersSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E30) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Row(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.primaryBlue, AppColors.accentCyan]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.layers_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text('Capas del mapa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                // Layer toggles
                _layerToggle(
                  isDark: isDark,
                  icon: Icons.videocam_rounded,
                  color: Colors.green,
                  title: 'Cámaras',
                  subtitle: 'Mostrar markers de cámaras',
                  value: _showCameras,
                  onChanged: (v) {
                    setSheetState(() => _showCameras = v);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 10),
                _layerToggle(
                  isDark: isDark,
                  icon: Icons.warning_rounded,
                  color: Colors.red,
                  title: 'Alertas',
                  subtitle: 'Cámaras con alertas activas',
                  value: _showAlerts,
                  onChanged: (v) {
                    setSheetState(() => _showAlerts = v);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 10),
                _layerToggle(
                  isDark: isDark,
                  icon: Icons.hexagon_outlined,
                  color: Colors.blue,
                  title: 'Zonas',
                  subtitle: 'Polígonos de zona definidos',
                  value: _showZones,
                  onChanged: (v) {
                    setSheetState(() => _showZones = v);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _layerToggle({
    required bool isDark,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? color.withOpacity(0.3)
              : (isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(value ? 0.15 : 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: value ? color : Colors.grey, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15,
                  color: value ? null : Colors.grey)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: color,
          ),
        ],
      ),
    );
  }
}

class _CameraMarker {
  final String id, name, zone;
  final LatLng location;
  final bool isOnline, hasAlert;

  _CameraMarker({
    required this.id, required this.name, required this.zone,
    required this.location, required this.isOnline, required this.hasAlert,
  });
}
