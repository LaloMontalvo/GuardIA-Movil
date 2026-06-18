import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../alerts/presentation/providers/alert_providers.dart';
import '../../../../app/theme/app_colors.dart';

class CreateReportScreen extends ConsumerStatefulWidget {
  const CreateReportScreen({super.key});

  @override
  ConsumerState<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedType;
  int _urgencyIndex = 0;
  final _descController = TextEditingController();
  
  bool _isSending = false;
  bool _isLoadingLocation = false;
  Position? _currentPosition;
  String _locationStatus = 'Ubicación no obtenida';

  final _incidentTypes = [
    'Robo',
    'Sospechoso',
    'Incendio',
    'Accidente',
    'Ruido',
    'Otro',
  ];

  final _urgencyLabels = ['Baja', 'Media', 'Alta'];
  final _urgencyColors = [
    AppColors.infoBlue,
    AppColors.warningYellow,
    AppColors.errorRed,
  ];

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationStatus = 'Obteniendo ubicación...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationStatus = 'GPS Desactivado';
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus = 'Permiso denegado';
            _isLoadingLocation = false;
          });
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = 'Permiso denegado permanentemente';
          _isLoadingLocation = false;
        });
        return;
      } 

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
        _locationStatus = 'Ubicación actualizada';
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationStatus = 'Error al obtener ubicación';
        _isLoadingLocation = false;
      });
    }
  }

  String _buildLocationJson() {
    if (_currentPosition == null) return '{}';
    return jsonEncode({
      "lat": _currentPosition!.latitude,
      "lng": _currentPosition!.longitude,
      "accuracy": _currentPosition!.accuracy,
      "timestamp": _currentPosition!.timestamp.toIso8601String(),
    });
  }

  void _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      _showResultDialog(
        success: false,
        title: 'Campo requerido',
        message: 'Selecciona el tipo de incidente antes de enviar.',
      );
      return;
    }

    final user = ref.read(authStateProvider).user;
    if (user == null) {
      _showResultDialog(
        success: false,
        title: 'Sin sesión',
        message: 'No se encontró una sesión activa. Inicia sesión e intenta de nuevo.',
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      // Mapear role de inglés a español para coincidir con el backend
      String roleForApi;
      switch (user.role.name) {
        case 'admin':
          roleForApi = 'admin';
          break;
        case 'operator':
          roleForApi = 'operador';
          break;
        default:
          roleForApi = 'operador';
      }

      await ref.read(alertRepositoryProvider).createReport(
        type: _selectedType!,
        priority: _urgencyLabels[_urgencyIndex].toLowerCase(),
        description: _descController.text.trim(),
        locationJson: _buildLocationJson(),
        createdByUserId: user.id, // Firebase UID
        role: roleForApi,
        status: "sent",
      );

      if (mounted) {
        setState(() => _isSending = false);
        _showResultDialog(
          success: true,
          title: '¡Reporte Enviado!',
          message: 'Tu reporte fue enviado correctamente. Las autoridades han sido notificadas.',
          onDismiss: () {
            _formKey.currentState?.reset();
            _descController.clear();
            setState(() {
              _selectedType = null;
              _urgencyIndex = 0;
            });
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        _showResultDialog(
          success: false,
          title: 'Error al Enviar',
          message: 'No se pudo enviar el reporte. Verifica tu conexión e intenta de nuevo.\n\nDetalle: $e',
        );
      }
    }
  }

  void _showResultDialog({
    required bool success,
    required String title,
    required String message,
    VoidCallback? onDismiss,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedAnim = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curvedAnim,
          child: FadeTransition(
            opacity: anim1,
            child: AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated icon container
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: success
                            ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                            : [const Color(0xFFF44336), const Color(0xFFEF5350)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (success ? const Color(0xFF4CAF50) : const Color(0xFFF44336))
                              .withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      success ? Icons.check_rounded : Icons.close_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onDismiss?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: success ? AppColors.successGreen : AppColors.errorRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        success ? 'Aceptar' : 'Intentar de nuevo',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Reporte', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1A1A3E) : AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isSending
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: isDark ? AppColors.accentCyan : AppColors.primaryBlue),
                  const SizedBox(height: 16),
                  const Text('Enviando reporte...', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  _buildSectionTitle('Tipo de Incidente'),
                  const SizedBox(height: 12),
                  _buildTypeChips(isDark),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Prioridad'),
                  const SizedBox(height: 12),
                  _buildPriorityChips(isDark),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Descripción del incidente'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descController,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'Detalles...',
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length < 5) return 'Mínimo 5 caracteres';
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Ubicación'),
                  const SizedBox(height: 12),
                  _buildLocationCard(theme, isDark),
                  
                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: const Text('Enviar Reporte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTypeChips(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 12,
      children: _incidentTypes.map((type) {
        final isSelected = _selectedType == type;
        return ChoiceChip(
          label: Text(type),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _selectedType = selected ? type : null);
          },
          selectedColor: isDark ? AppColors.accentCyan.withValues(alpha: 0.2) : AppColors.primaryBlue.withValues(alpha: 0.1),
          labelStyle: TextStyle(
            color: isSelected 
                ? (isDark ? AppColors.accentCyan : AppColors.primaryBlue) 
                : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
          side: isSelected 
              ? BorderSide(color: isDark ? AppColors.accentCyan : AppColors.primaryBlue) 
              : BorderSide.none,
        );
      }).toList(),
    );
  }

  Widget _buildPriorityChips(bool isDark) {
    return Row(
      children: List.generate(3, (index) {
        final isSelected = _urgencyIndex == index;
        final color = _urgencyColors[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < 2 ? 8 : 0),
            child: InkWell(
              onTap: () => setState(() => _urgencyIndex = index),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.15) : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _urgencyLabels[index],
                  style: TextStyle(
                    color: isSelected ? color : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLocationCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_rounded, 
                color: _currentPosition != null ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_locationStatus, style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (_currentPosition != null)
                      Text(
                        '${_currentPosition!.latitude.toStringAsFixed(5)}, ${_currentPosition!.longitude.toStringAsFixed(5)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                  ],
                ),
              ),
              if (_isLoadingLocation)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              else
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _fetchLocation,
                  tooltip: 'Actualizar Ubicación',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
