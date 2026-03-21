import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/media_picker_sheet.dart';

/// Estado de emergencia en curso — cronómetro + ubicación + notas
class OperatorEmergencyActiveScreen extends StatefulWidget {
  const OperatorEmergencyActiveScreen({super.key});

  @override
  State<OperatorEmergencyActiveScreen> createState() => _OperatorEmergencyActiveScreenState();
}

class _OperatorEmergencyActiveScreenState extends State<OperatorEmergencyActiveScreen> {
  int _elapsedSeconds = 0;
  Timer? _timer;
  final _noteController = TextEditingController();
  final List<String> _notes = [];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _noteController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _addNote() {
    final text = _noteController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _notes.add(text);
        _noteController.clear();
      });
    }
  }

  void _endEmergency() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Finalizar emergencia',
      message: '¿Estás seguro de que quieres finalizar la alerta de emergencia?',
      confirmText: 'Finalizar',
      isDangerous: true,
      icon: Icons.check_circle_outline,
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emergencia finalizada'), backgroundColor: Colors.green),
      );
      context.go('/operator-home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryBlue, Color(0xFF0A0A1A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          const Text('EMERGENCIA ACTIVA',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(_formatDuration(_elapsedSeconds),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold,
                            fontFamily: 'monospace')),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Location card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.my_location_rounded, color: Colors.green, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ubicación en vivo',
                                style: TextStyle(color: Colors.green.shade300, fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('Transmitiendo cada 15 segundos',
                                style: TextStyle(color: Colors.green.withValues(alpha: 0.6), fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('ON',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Notes section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notas rápidas',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      // Add note
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _noteController,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Agregar comentario...',
                                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.06),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _addNote,
                            icon: const Icon(Icons.send_rounded, color: AppColors.accentCyan),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.accentCyan.withValues(alpha: 0.15),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () async {
                              final result = await MediaPickerSheet.show(context);
                              if (result != null) {
                                setState(() => _notes.add('📷 Evidencia: ${result.name}'));
                              }
                            },
                            icon: const Icon(Icons.camera_alt_rounded, color: Colors.white70),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Notes list
                      Expanded(
                        child: _notes.isEmpty
                            ? Center(
                                child: Text('Agrega notas o evidencias',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.3))),
                              )
                            : ListView.builder(
                                itemCount: _notes.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.06),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(_formatDuration(_elapsedSeconds - (_notes.length - index) * 10),
                                            style: TextStyle(
                                                color: AppColors.accentCyan, fontSize: 11,
                                                fontFamily: 'monospace')),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(_notes[index],
                                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // End button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _endEmergency,
                    icon: const Icon(Icons.stop_circle_rounded),
                    label: const Text('Finalizar emergencia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
