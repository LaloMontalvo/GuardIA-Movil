import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Live view de la cámara del operador
class OperatorCameraLiveScreen extends StatefulWidget {
  const OperatorCameraLiveScreen({super.key});

  @override
  State<OperatorCameraLiveScreen> createState() => _OperatorCameraLiveScreenState();
}

class _OperatorCameraLiveScreenState extends State<OperatorCameraLiveScreen> {
  String _quality = 'auto';
  bool _isMuted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('En vivo — Entrada Principal',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Video area
          Expanded(
            child: Container(
              color: const Color(0xFF0A0A0A),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam_rounded, size: 64, color: Colors.grey.shade700),
                    const SizedBox(height: 12),
                    Text('Stream en vivo',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Cámara Entrada Principal',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),

          // Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Quality selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _QualityChip(label: 'Auto', isSelected: _quality == 'auto', onTap: () => setState(() => _quality = 'auto')),
                      _QualityChip(label: 'HD', isSelected: _quality == 'high', onTap: () => setState(() => _quality = 'high')),
                      _QualityChip(label: 'SD', isSelected: _quality == 'medium', onTap: () => setState(() => _quality = 'medium')),
                      _QualityChip(label: 'Bajo', isSelected: _quality == 'low', onTap: () => setState(() => _quality = 'low')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ControlButton(
                        icon: Icons.fullscreen_rounded,
                        label: 'Pantalla\ncompleta',
                        onTap: () {},
                      ),
                      _ControlButton(
                        icon: Icons.camera_alt_rounded,
                        label: 'Captura',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Captura tomada'), backgroundColor: Colors.green),
                          );
                        },
                      ),
                      _ControlButton(
                        icon: _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                        label: _isMuted ? 'Silenciado' : 'Audio',
                        isActive: !_isMuted,
                        onTap: () => setState(() => _isMuted = !_isMuted),
                      ),
                      _ControlButton(
                        icon: Icons.report_problem_rounded,
                        label: 'Reportar',
                        color: Colors.orange,
                        onTap: () => Navigator.pop(context), // goes back, user can navigate to report
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QualityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _QualityChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentCyan.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.accentCyan : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.accentCyan : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool isActive;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? (isActive ? Colors.white : Colors.grey);
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
              style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
