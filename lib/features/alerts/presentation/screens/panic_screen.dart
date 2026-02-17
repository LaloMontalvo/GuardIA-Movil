import 'dart:async';
import 'package:flutter/material.dart';

/// Pantalla dedicada de botón de pánico
class PanicScreen extends StatefulWidget {
  const PanicScreen({super.key});

  @override
  State<PanicScreen> createState() => _PanicScreenState();
}

class _PanicScreenState extends State<PanicScreen> with SingleTickerProviderStateMixin {
  bool _holding = false;
  bool _sent = false;
  double _holdProgress = 0;
  Timer? _holdTimer;
  int _cancelCountdown = 5;
  Timer? _cancelTimer;

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

  void _sendPanic() {
    setState(() {
      _sent = true;
      _cancelCountdown = 5;
    });

    _cancelTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _cancelCountdown--;
        if (_cancelCountdown <= 0) {
          timer.cancel();
          // Alerta enviada definitivamente
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡ALERTA DE PÁNICO ENVIADA!'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Botón de Pánico'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade700, Colors.red.shade900],
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
        Text(
          'Mantén presionado\npara enviar alerta',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        GestureDetector(
          onLongPressStart: (_) => _startHold(),
          onLongPressEnd: (_) => _stopHold(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: _holdProgress,
                  strokeWidth: 8,
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                ),
              ),
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _holding ? Colors.red.shade300 : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.emergency,
                  size: 80,
                  color: _holding ? Colors.white : Colors.red,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Mantén presionado 3 segundos',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        const SizedBox(height: 48),
        // Emergency contacts
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text('Contactos de emergencia', style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
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
        const Icon(Icons.warning_rounded, size: 100, color: Colors.white),
        const SizedBox(height: 24),
        Text(
          '¡ALERTA ENVIADA!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tu ubicación y datos han sido enviados',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
        ),
        const SizedBox(height: 32),
        if (_cancelCountdown > 0)
          Column(
            children: [
              Text(
                'Puedes cancelar en $_cancelCountdown segundos',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _cancelPanic,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('CANCELAR'),
              ),
            ],
          ),
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
          Icon(Icons.phone, color: Colors.white.withOpacity(0.7), size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: TextStyle(color: Colors.white.withOpacity(0.9)))),
          Text(phone, style: TextStyle(color: Colors.white.withOpacity(0.7))),
        ],
      ),
    );
  }
}
