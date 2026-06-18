import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/app_providers.dart';

/// Mi Cámara del operador — preview en vivo de la cámara del dispositivo
class OperatorMyCameraScreen extends ConsumerStatefulWidget {
  const OperatorMyCameraScreen({super.key});

  @override
  ConsumerState<OperatorMyCameraScreen> createState() =>
      _OperatorMyCameraScreenState();
}

class _OperatorMyCameraScreenState
    extends ConsumerState<OperatorMyCameraScreen> {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isInitializing = true;
  String _errorMessage = '';
  bool _isServerConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _checkServerConnection();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'No se encontraron cámaras';
        });
        return;
      }

      // Use back camera by default
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraReady = true;
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'Error al inicializar cámara';
        });
      }
    }
  }

  Future<void> _checkServerConnection() async {
    final iaBaseUrl = ref.read(iaBaseUrlProvider);
    if (iaBaseUrl.isEmpty) {
      setState(() => _isServerConnected = false);
      return;
    }

    try {
      final dio = Dio();
      final response = await dio.get(
        '$iaBaseUrl/health',
        options: Options(receiveTimeout: const Duration(seconds: 3)),
      );
      if (mounted) {
        setState(
            () => _isServerConnected = response.statusCode == 200);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isServerConnected = false);
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iaBaseUrl = ref.watch(iaBaseUrlProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Cámara',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor:
            isDark ? const Color(0xFF1A1A3E) : AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cámara principal
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  _isServerConnected
                      ? Colors.green.shade600
                      : Colors.orange.shade600,
                  _isServerConnected
                      ? Colors.green.shade400
                      : Colors.orange.shade400,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: (_isServerConnected ? Colors.green : Colors.orange)
                      .withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    // Live camera preview
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18)),
                      child: Container(
                        height: 240,
                        width: double.infinity,
                        color: Colors.black,
                        child: _buildCameraPreview(),
                      ),
                    ),
                    // Camera info
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (isDark
                                          ? AppColors.accentCyan
                                          : AppColors.primaryBlue)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.videocam_rounded,
                                    color: isDark
                                        ? AppColors.accentCyan
                                        : AppColors.primaryBlue,
                                    size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Cámara del Dispositivo',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                                fontWeight:
                                                    FontWeight.bold)),
                                    Text(
                                        iaBaseUrl.isEmpty
                                            ? 'Servidor IA no configurado'
                                            : _isServerConnected
                                                ? 'Conectado al servidor IA'
                                                : 'Servidor IA desconectado',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Stats
                          Row(
                            children: [
                              _CameraStat(
                                icon: Icons.signal_wifi_4_bar,
                                label: 'Servidor',
                                value: _isServerConnected
                                    ? 'Online'
                                    : 'Offline',
                                color: _isServerConnected
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 12),
                              _CameraStat(
                                icon: Icons.hd_rounded,
                                label: 'Calidad',
                                value: 'HD',
                                color: isDark
                                    ? AppColors.accentCyan
                                    : AppColors.primaryBlue,
                              ),
                              const SizedBox(width: 12),
                              _CameraStat(
                                icon: Icons.psychology_rounded,
                                label: 'IA',
                                value: _isServerConnected
                                    ? 'Lista'
                                    : 'N/A',
                                color: _isServerConnected
                                    ? Colors.teal
                                    : Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Actions
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  context.push('/operator-camera-live'),
                              icon:
                                  const Icon(Icons.play_arrow_rounded),
                              label: const Text('Ver en vivo',
                                  style: TextStyle(fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? AppColors.primaryBlueLight
                                    : AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _checkServerConnection();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Verificando conexión...')),
                                    );
                                  },
                                  icon: const Icon(
                                      Icons.refresh_rounded,
                                      size: 18),
                                  label: const Text('Reconectar',
                                      style: TextStyle(fontSize: 13)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      context.push('/operator-report'),
                                  icon: const Icon(
                                      Icons.report_problem_rounded,
                                      size: 18),
                                  label: const Text('Reportar',
                                      style: TextStyle(fontSize: 13)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.orange,
                                    side: const BorderSide(
                                        color: Colors.orange),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Server config hint if not configured
          if (iaBaseUrl.isEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Colors.orange, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Servidor IA no configurado',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                            'Ve a Ajustes → Servidor IA para configurar la IP de tu computadora.',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isInitializing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.accentCyan,
              strokeWidth: 2,
            ),
            const SizedBox(height: 8),
            Text('Iniciando cámara...',
                style:
                    TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          ],
        ),
      );
    }

    if (!_isCameraReady || _cameraController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off_rounded,
                size: 48,
                color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : 'Cámara no disponible',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview fills the container
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _cameraController!.value.previewSize!.height,
            height: _cameraController!.value.previewSize!.width,
            child: CameraPreview(_cameraController!),
          ),
        ),
        // Status badge
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _isServerConnected ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: (_isServerConnected
                          ? Colors.green
                          : Colors.orange)
                      .withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isServerConnected ? 'EN LÍNEA' : 'SIN SERVIDOR',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        ),
        // Camera label
        Positioned(
          bottom: 8,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videocam_rounded,
                    color: Colors.white70, size: 14),
                SizedBox(width: 6),
                Text('CÁMARA EN VIVO',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CameraStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _CameraStat(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: color)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
