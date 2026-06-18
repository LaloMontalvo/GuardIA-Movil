import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../alerts/presentation/providers/alert_providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/confirm_dialog.dart';

/// Pantalla de Pánico del Operador — alto contraste con theme GuardIA
class OperatorPanicScreen extends ConsumerStatefulWidget {
  const OperatorPanicScreen({super.key});

  @override
  ConsumerState<OperatorPanicScreen> createState() => _OperatorPanicScreenState();
}

class _OperatorPanicScreenState extends ConsumerState<OperatorPanicScreen>
    with SingleTickerProviderStateMixin {
  bool _holding = false;
  bool _sent = false;
  double _holdProgress = 0;
  Timer? _holdTimer;
  int _cancelCountdown = 5;
  Timer? _cancelTimer;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  void _startHold() {
    setState(() {
      _holding = true;
      _holdProgress = 0;
    });

    _holdTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        _holdProgress += 0.01;
        if (_holdProgress >= 1.0) {
          _holdProgress = 1.0;
          timer.cancel();
          _sendPanic();
        }
      });
    });
  }

  void _stopHold() {
    _holdTimer?.cancel();
    if (!_sent) {
      setState(() {
        _holding = false;
        _holdProgress = 0;
      });
    }
  }

  void _sendPanic() async {
    setState(() {
      _sent = true;
      _cancelCountdown = 5;
    });

    try {
      await ref.read(alertRepositoryProvider).sendPanic();
    } catch (e) {
      debugPrint('Error enviando pánico: $e');
    }

    _cancelTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _cancelCountdown--;
        if (_cancelCountdown <= 0) {
          timer.cancel();
          // Navigate to emergency active
          if (mounted) {
            context.pushReplacement('/operator-emergency-active');
          }
        }
      });
    });
  }

  void _cancelPanic() {
    _cancelTimer?.cancel();
    setState(() {
      _sent = false;
      _holding = false;
      _holdProgress = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alerta de pánico cancelada')),
    );
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _cancelTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Botón de Pánico', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryBlue,
              Color(0xFF0A0A1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: _sent ? _buildSentView() : _buildPanicButton(),
          ),
        ),
      ),
    );
  }

  Widget _buildPanicButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Usar solo en emergencias',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        Text(
          'Mantén presionado\npara activar',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onLongPressStart: (_) => _startHold(),
          onLongPressEnd: (_) => _stopHold(),
          child: AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (context, child) {
              return Container(
                width: 220 + (_pulseCtrl.value * 8),
                height: 220 + (_pulseCtrl.value * 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress ring
                    SizedBox(
                      width: 210,
                      height: 210,
                      child: CircularProgressIndicator(
                        value: _holdProgress,
                        strokeWidth: 6,
                        color: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    // Main button
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _holding
                              ? [const Color(0xFFFF1744), const Color(0xFFD50000)]
                              : [const Color(0xFFE53935), const Color(0xFFC62828)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: _holding ? 0.6 : 0.3),
                            blurRadius: _holding ? 40 : 20,
                            spreadRadius: _holding ? 8 : 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.emergency_rounded,
                        size: 72,
                        color: Colors.white.withValues(alpha: _holding ? 1 : 0.9),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Mantén presionado 3 segundos',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
        ),
        const SizedBox(height: 48),
        // Emergency contacts
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            children: [
              Text('Contactos de emergencia',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 10),
              _EmergencyContact(name: 'Seguridad Central', phone: '55-1234-5678'),
              _EmergencyContact(name: 'Emergencias', phone: '911'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSentView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withValues(alpha: 0.2),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withValues(alpha: 0.3),
            ),
            child: const Icon(Icons.warning_rounded, size: 64, color: Colors.white),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          '¡ALERTA ENVIADA!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tu ubicación y datos han sido enviados',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 15),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.my_location_rounded, color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Text('Ubicación en vivo activada',
                  style: TextStyle(color: Colors.green.shade300, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        if (_cancelCountdown > 0) ...[
          Text(
            'Puedes cancelar en $_cancelCountdown segundos',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _cancelPanic,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('CANCELAR', style: TextStyle(letterSpacing: 1)),
          ),
        ],
      ],
    );
  }
}

class _EmergencyContact extends StatelessWidget {
  final String name;
  final String phone;
  const _EmergencyContact({required this.name, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.phone_rounded, color: Colors.white.withValues(alpha: 0.6), size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13))),
          Text(phone, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
        ],
      ),
    );
  }
}
