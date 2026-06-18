import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/app_providers.dart';

/// Live view de la cámara del operador — transmite frames al servidor IA
class OperatorCameraLiveScreen extends ConsumerStatefulWidget {
  const OperatorCameraLiveScreen({super.key});

  @override
  ConsumerState<OperatorCameraLiveScreen> createState() =>
      _OperatorCameraLiveScreenState();
}

class _OperatorCameraLiveScreenState
    extends ConsumerState<OperatorCameraLiveScreen> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraReady = false;
  bool _isStreaming = false;
  bool _isInitializing = true;
  int _selectedCameraIndex = 0;
  Timer? _streamTimer;
  int _framesSent = 0;
  int _framesErrors = 0;
  String _statusMessage = 'Inicializando cámara...';
  String _connectionStatus = 'desconectado';
  bool _isProcessingFrame = false;
  bool _detectionStarted = false;

  // Streaming interval in milliseconds (increased to 500ms to avoid crashing Android's camera HAL)
  static const int _streamIntervalMs = 500;

  @override
  void initState() {
    super.initState();
    // Hide system UI for immersive fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _isInitializing = false;
          _statusMessage = 'No se encontraron cámaras disponibles';
        });
        return;
      }
      // Default to back camera (index 0)
      await _setupCamera(_selectedCameraIndex);
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _statusMessage = 'Error al inicializar cámara: $e';
      });
    }
  }

  Future<void> _setupCamera(int index) async {
    if (_cameras.isEmpty) return;

    // Dispose previous controller if exists
    await _cameraController?.dispose();

    setState(() {
      _isCameraReady = false;
      _isInitializing = true;
      _statusMessage = 'Configurando cámara...';
    });

    final camera = _cameras[index];
    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraReady = true;
          _isInitializing = false;
          _selectedCameraIndex = index;
          _statusMessage = 'Cámara lista';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _statusMessage = 'Error: $e';
        });
      }
    }
  }

  void _toggleCamera() {
    if (_cameras.length < 2) return;
    final wasStreaming = _isStreaming;
    if (wasStreaming) _stopStreaming();
    final nextIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _setupCamera(nextIndex).then((_) {
      if (wasStreaming && _isCameraReady) _startStreaming();
    });
  }

  void _startStreaming() {
    final iaBaseUrl = ref.read(iaBaseUrlProvider);
    if (iaBaseUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Configura la IP del servidor IA en Ajustes antes de transmitir'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isStreaming = true;
      _framesSent = 0;
      _framesErrors = 0;
      _connectionStatus = 'conectando...';
      _statusMessage = 'Transmitiendo al servidor IA...';
    });

    // Auto-start detection on the server
    _startDetectionOnServer();

    _streamTimer =
        Timer.periodic(const Duration(milliseconds: _streamIntervalMs), (_) {
      _captureAndSendFrame();
    });
  }

  void _stopStreaming() {
    _streamTimer?.cancel();
    _streamTimer = null;

    // Auto-stop detection on the server
    _stopDetectionOnServer();

    setState(() {
      _isStreaming = false;
      _connectionStatus = 'desconectado';
      _statusMessage = 'Transmisión detenida';
    });
  }

  /// Auto-start person detection on the IA server for cam-phone
  Future<void> _startDetectionOnServer() async {
    final iaBaseUrl = ref.read(iaBaseUrlProvider);
    if (iaBaseUrl.isEmpty) return;

    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));

      final cameraId = ref.read(iaCameraIdProvider);
      await dio.post(
        '$iaBaseUrl/detections/start',
        data: {
          'cameraId': cameraId,
          'model': 'yolov8n.pt',
          'confidence': 0.50,
          'saveCooldown': 2.0,
          'eventResetSeconds': 5.0,
        },
      );

      _detectionStarted = true;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔍 Detección IA activada'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Detection may already be running — that's ok (409 conflict)
      _detectionStarted = false;
    }
  }

  /// Auto-stop person detection on the IA server
  Future<void> _stopDetectionOnServer() async {
    if (!_detectionStarted) return;

    final iaBaseUrl = ref.read(iaBaseUrlProvider);
    if (iaBaseUrl.isEmpty) return;

    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));

      await dio.post('$iaBaseUrl/detections/stop');
      _detectionStarted = false;
    } catch (_) {
      // Ignore errors when stopping
    }
  }

  Future<void> _captureAndSendFrame() async {
    if (!_isCameraReady || _cameraController == null) return;
    if (!_cameraController!.value.isInitialized) return;
    if (_isProcessingFrame) return; // Evitar llamadas superpuestas si la foto anterior no ha terminado

    setState(() {
      _isProcessingFrame = true;
    });

    try {
      final xFile = await _cameraController!.takePicture();
      final bytes = await File(xFile.path).readAsBytes();
      // Clean up the temp file
      File(xFile.path).delete().catchError((_) {});

      final iaBaseUrl = ref.read(iaBaseUrlProvider);
      if (iaBaseUrl.isEmpty) return;

      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
      ));

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: 'frame.jpg'),
      });

      final cameraId = ref.read(iaCameraIdProvider);
      final response = await dio.post(
        '$iaBaseUrl/cameras/$cameraId/upload_frame',
        data: formData,
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _framesSent++;
            _connectionStatus = 'conectado';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _framesErrors++;
          _connectionStatus = 'error';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingFrame = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _streamTimer?.cancel();
    if (_detectionStarted) {
      _stopDetectionOnServer();
    }
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Cámara IA — En vivo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          // Connection status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _isStreaming ? Colors.red : Colors.grey.shade800,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _isStreaming ? Colors.white : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _isStreaming ? 'LIVE' : 'OFF',
                  style: TextStyle(
                    color: _isStreaming ? Colors.white : Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Camera preview area — FULLSCREEN
          Expanded(
            child: Container(
              color: Colors.black,
              child: _buildCameraPreview(),
            ),
          ),

          // Status info bar
          _buildStatusBar(),

          // Controls
          _buildControlsBar(),
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
            const CircularProgressIndicator(
              color: AppColors.accentCyan,
              strokeWidth: 2,
            ),
            const SizedBox(height: 12),
            Text(_statusMessage,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
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
                size: 64, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(_statusMessage,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4), fontSize: 14)),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview — FULLSCREEN with cover fit
        ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width *
                  _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            ),
          ),
        ),

        // Streaming overlay indicator
        if (_isStreaming)
          Positioned(
            top: MediaQuery.of(context).padding.top + 56,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('REC',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                ],
              ),
            ),
          ),

        // Frame counter
        if (_isStreaming)
          Positioned(
            top: MediaQuery.of(context).padding.top + 56,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Frames: $_framesSent',
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),

        // Detection IA badge
        if (_isStreaming && _detectionStarted)
          Positioned(
            top: MediaQuery.of(context).padding.top + 86,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.psychology_rounded,
                      color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('IA Activa',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

        // Camera name overlay
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${ref.watch(iaCameraIdProvider).toUpperCase()} | ${_cameras.isNotEmpty ? (_cameras[_selectedCameraIndex].lensDirection == CameraLensDirection.back ? 'Trasera' : 'Frontal') : 'N/A'}',
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    final statusColor = switch (_connectionStatus) {
      'conectado' => Colors.green,
      'conectando...' => Colors.amber,
      'error' => Colors.red,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF111111),
      child: Row(
        children: [
          // Connection status dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _connectionStatus.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          if (_isStreaming) ...[
            Text(
              'Enviados: $_framesSent',
              style:
                  const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            const SizedBox(width: 12),
            if (_framesErrors > 0)
              Text(
                'Errores: $_framesErrors',
                style: const TextStyle(color: Colors.red, fontSize: 11),
              ),
          ],
          if (!_isStreaming)
            Text(
              _statusMessage,
              style:
                  const TextStyle(color: Colors.white38, fontSize: 11),
            ),
        ],
      ),
    );
  }

  Widget _buildControlsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Switch camera
            _ControlButton(
              icon: Icons.cameraswitch_rounded,
              label: 'Cambiar\ncámara',
              onTap: _cameras.length >= 2 ? _toggleCamera : null,
            ),

            // Main streaming button
            _StreamButton(
              isStreaming: _isStreaming,
              onTap: _isCameraReady
                  ? () {
                      if (_isStreaming) {
                        _stopStreaming();
                      } else {
                        _startStreaming();
                      }
                    }
                  : null,
            ),

            // Capture snapshot
            _ControlButton(
              icon: Icons.camera_alt_rounded,
              label: 'Captura',
              onTap: _isCameraReady
                  ? () async {
                      try {
                        final xFile =
                            await _cameraController!.takePicture();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Captura guardada: ${xFile.name}'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al capturar'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  : null,
            ),

            // Back / report
            _ControlButton(
              icon: Icons.arrow_back_rounded,
              label: 'Volver',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main streaming toggle button with animated ring
class _StreamButton extends StatelessWidget {
  final bool isStreaming;
  final VoidCallback? onTap;

  const _StreamButton({required this.isStreaming, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isStreaming
                  ? const LinearGradient(
                      colors: [Colors.red, Colors.deepOrange])
                  : const LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.accentCyan]),
              boxShadow: [
                BoxShadow(
                  color: (isStreaming ? Colors.red : AppColors.accentCyan)
                      .withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              isStreaming ? Icons.stop_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isStreaming ? 'Detener' : 'Transmitir',
            style: TextStyle(
              color: isStreaming ? Colors.red : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? (onTap != null ? Colors.white : Colors.grey.shade700);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: c, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
              style:
                  TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
