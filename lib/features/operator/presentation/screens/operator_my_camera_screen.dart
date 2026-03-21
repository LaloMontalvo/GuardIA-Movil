import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';

/// Mi Cámara del operador — vista de cámara asignada
class OperatorMyCameraScreen extends StatelessWidget {
  const OperatorMyCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Cámara', style: TextStyle(fontWeight: FontWeight.bold)),
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
                colors: [Colors.green.shade600, Colors.green.shade400],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.25),
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
                    // Preview area
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade100,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.videocam_rounded, size: 52, color: Colors.grey.shade300),
                                const SizedBox(height: 8),
                                Text('Vista previa',
                                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                              ],
                            ),
                          ),
                          // Status badge
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6, height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('EN LÍNEA',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5)),
                                ],
                              ),
                            ),
                          ),
                        ],
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
                                  color: (isDark ? AppColors.accentCyan : AppColors.primaryBlue).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.videocam_rounded,
                                    color: isDark ? AppColors.accentCyan : AppColors.primaryBlue, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Cámara Entrada Principal',
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                    Text('Zona A — Asignada a ti',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Stats
                          Row(
                            children: [
                              _CameraStat(icon: Icons.signal_wifi_4_bar, label: 'Señal', value: 'Buena', color: Colors.green),
                              const SizedBox(width: 12),
                              _CameraStat(icon: Icons.hd_rounded, label: 'Calidad', value: 'HD', color: isDark ? AppColors.accentCyan : AppColors.primaryBlue),
                              const SizedBox(width: 12),
                              _CameraStat(icon: Icons.timer_rounded, label: 'Uptime', value: '99.8%', color: Colors.teal),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Actions
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/operator-camera-live'),
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Ver en vivo', style: TextStyle(fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Captura tomada')),
                                    );
                                  },
                                  icon: const Icon(Icons.camera_alt_rounded, size: 18),
                                  label: const Text('Captura', style: TextStyle(fontSize: 13)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => context.push('/operator-report'),
                                  icon: const Icon(Icons.report_problem_rounded, size: 18),
                                  label: const Text('Reportar', style: TextStyle(fontSize: 13)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.orange,
                                    side: const BorderSide(color: Colors.orange),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        ],
      ),
    );
  }
}

class _CameraStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _CameraStat({required this.icon, required this.label, required this.value, required this.color});

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
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
