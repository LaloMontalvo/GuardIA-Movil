import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/camera.dart';
import 'camera_status_chip.dart';
import '../../../../app/theme/app_colors.dart';

/// Premium camera card with gradient accent border and pulsing status dot
class CameraCard extends StatefulWidget {
  final Camera camera;

  const CameraCard({super.key, required this.camera});

  @override
  State<CameraCard> createState() => _CameraCardState();
}

class _CameraCardState extends State<CameraCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.camera.isOnline) _pulseCtrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = widget.camera.status.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.cardColor,
          border: Border.all(
            color: statusColor.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/camera/${widget.camera.id}'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  // Status icon with gradient background
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          statusColor.withValues(alpha: 0.15),
                          statusColor.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      widget.camera.status.icon,
                      size: 28,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Camera info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.camera.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.camera.isFavorite)
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.camera.location,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Pulsing online dot
                            AnimatedBuilder(
                              animation: _pulseCtrl,
                              builder: (context, _) => Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.camera.isOnline ? Colors.green : Colors.grey,
                                  boxShadow: widget.camera.isOnline
                                      ? [
                                          BoxShadow(
                                            color: Colors.green.withValues(
                                                alpha: 0.3 + _pulseCtrl.value * 0.4),
                                            blurRadius: 4 + _pulseCtrl.value * 4,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            CameraStatusChip(status: widget.camera.status),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (theme.brightness == Brightness.dark ? Colors.white : AppColors.primaryBlue).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.camera.zone,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.brightness == Brightness.dark ? Colors.white : AppColors.primaryBlue,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
