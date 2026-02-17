import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Pantalla de vista en vivo — Premium
class LiveViewScreen extends StatefulWidget {
  final String cameraId;

  const LiveViewScreen({super.key, required this.cameraId});

  @override
  State<LiveViewScreen> createState() => _LiveViewScreenState();
}

class _LiveViewScreenState extends State<LiveViewScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanCtrl;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Cámara ${widget.cameraId}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (context, _) => Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15 + _pulseCtrl.value * 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fiber_manual_record, color: Colors.red, size: 10),
                  SizedBox(width: 4),
                  Text('LIVE', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Video area with scan line
          Expanded(
            child: Stack(
              children: [
                // Placeholder
                Container(
                  width: double.infinity,
                  color: const Color(0xFF0A0A1A),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam_rounded, size: 64,
                          color: Colors.white.withValues(alpha: 0.1)),
                      const SizedBox(height: 16),
                      Text('Streaming próximamente',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('La vista en vivo está siendo configurada',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 13)),
                    ],
                  ),
                ),
                // Animated scan line
                AnimatedBuilder(
                  animation: _scanCtrl,
                  builder: (context, _) => Positioned(
                    top: _scanCtrl.value * MediaQuery.of(context).size.height * 0.5,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.accentCyan.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Corner brackets
                ..._buildCornerBrackets(),
              ],
            ),
          ),

          // Controls bar with frosted glass effect
          Container(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF111128),
              border: Border(
                top: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.15)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ControlButton(
                  icon: Icons.hd_outlined,
                  label: 'HD',
                  onTap: () {},
                ),
                _ControlButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Captura',
                  isPrimary: true,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Captura guardada (simulado)')),
                    );
                  },
                ),
                _ControlButton(
                  icon: Icons.bookmark_outline_rounded,
                  label: 'Marcar',
                  onTap: () {},
                ),
                _ControlButton(
                  icon: Icons.fullscreen_rounded,
                  label: 'Pantalla',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerBrackets() {
    const size = 20.0;
    const thickness = 2.0;
    final color = AppColors.accentCyan.withValues(alpha: 0.3);

    Widget corner(Alignment alignment) {
      final isTop = alignment == Alignment.topLeft || alignment == Alignment.topRight;
      final isLeft = alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;

      return Positioned(
        top: isTop ? 10 : null,
        bottom: !isTop ? 10 : null,
        left: isLeft ? 10 : null,
        right: !isLeft ? 10 : null,
        child: SizedBox(
          width: size, height: size,
          child: CustomPaint(
            painter: _CornerPainter(
              color: color,
              thickness: thickness,
              topLeft: alignment == Alignment.topLeft,
              topRight: alignment == Alignment.topRight,
              bottomLeft: alignment == Alignment.bottomLeft,
              bottomRight: alignment == Alignment.bottomRight,
            ),
          ),
        ),
      );
    }

    return [
      corner(Alignment.topLeft),
      corner(Alignment.topRight),
      corner(Alignment.bottomLeft),
      corner(Alignment.bottomRight),
    ];
  }
}

class _ControlButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 100),
      lowerBound: 0.9, upperBound: 1.0, value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.reverse(),
      onTapUp: (_) { _scaleCtrl.forward(); widget.onTap(); },
      onTapCancel: () => _scaleCtrl.forward(),
      child: ScaleTransition(
        scale: _scaleCtrl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: widget.isPrimary
                    ? const LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.accentCyan],
                      )
                    : null,
                color: widget.isPrimary ? null : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(widget.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 6),
            Text(widget.label,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool topLeft, topRight, bottomLeft, bottomRight;

  _CornerPainter({
    required this.color,
    required this.thickness,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (topLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (topRight) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (bottomLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else if (bottomRight) {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
