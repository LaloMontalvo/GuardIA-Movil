import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cameras/domain/entities/camera.dart';
import '../../../cameras/presentation/providers/camera_providers.dart';
import '../../../alerts/domain/entities/alert.dart';
import '../../../alerts/presentation/providers/alert_providers.dart';
import '../../../../core/di/app_providers.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../app/theme/app_colors.dart';

/// Dashboard del vecino — estado de zona, favoritas, accesos rápidos, alertas
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _staggerController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  final List<Animation<double>> _itemFades = [];
  final List<Animation<Offset>> _itemSlides = [];
  static const _itemCount = 4;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -20), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic));

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    for (int i = 0; i < _itemCount; i++) {
      final start = i * 0.15;
      final end = min(start + 0.5, 1.0);
      _itemFades.add(Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _staggerController, curve: Interval(start, end, curve: Curves.easeOut)),
      ));
      _itemSlides.add(Tween<Offset>(begin: const Offset(0, 30), end: Offset.zero).animate(
        CurvedAnimation(parent: _staggerController, curve: Interval(start, end, curve: Curves.easeOutCubic)),
      ));
    }

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  Widget _animatedItem(int index, Widget child) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, _) => Opacity(
        opacity: _itemFades[index].value,
        child: Transform.translate(
          offset: _itemSlides[index].value,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final camerasAsync = ref.watch(camerasProvider);
    final alertsAsync = ref.watch(alertsProvider);
    final favorites = ref.watch(favoriteCamerasProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(camerasProvider);
          ref.invalidate(alertsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Gradient Header
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _headerController,
                builder: (context, _) => Opacity(
                  opacity: _headerFade.value,
                  child: Transform.translate(
                    offset: _headerSlide.value,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 16,
                        left: 20,
                        right: 20,
                        bottom: 24,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A3E) : AppColors.primaryBlue,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hola, ${user?.name ?? "Vecino"}',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getGreeting(),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildNotificationBell(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. Zone Status
                  _animatedItem(0, _buildZoneStatus(context, camerasAsync, isDark)),
                  const SizedBox(height: 20),

                  // 2. Quick Actions
                  _animatedItem(1, _buildQuickActions(context)),
                  const SizedBox(height: 20),

                  // 3. Favorite Cameras
                  _animatedItem(2, _buildFavoriteCameras(context, camerasAsync, favorites)),
                  const SizedBox(height: 20),

                  // 4. Recent Alerts
                  _animatedItem(3, _buildRecentAlerts(context, alertsAsync)),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/panic'),
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.emergency),
        label: const Text('PÁNICO', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildNotificationBell(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: IconButton(
        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
        onPressed: () => context.push('/notifications'),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días — tu zona está segura';
    if (hour < 18) return 'Buenas tardes — todo en orden';
    return 'Buenas noches — vigilancia activa';
  }

  /// Zone status card with gradient border
  Widget _buildZoneStatus(BuildContext context, AsyncValue<List<Camera>> camerasAsync, bool isDark) {
    final theme = Theme.of(context);

    return camerasAsync.when(
      data: (cameras) {
        final online = cameras.where((c) => c.isOnline).length;
        final offline = cameras.length - online;
        final allOnline = offline == 0;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: allOnline
                  ? [const Color(0xFF43A047), const Color(0xFF66BB6A)]
                  : [Colors.orange.shade600, Colors.orange.shade400],
            ),
            boxShadow: [
              BoxShadow(
                color: (allOnline ? Colors.green : Colors.orange).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: allOnline
                            ? [Colors.green.withValues(alpha: 0.08), Colors.green.withValues(alpha: 0.02)]
                            : [Colors.orange.withValues(alpha: 0.08), Colors.orange.withValues(alpha: 0.02)],
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (allOnline ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            allOnline ? Icons.shield_rounded : Icons.warning_amber_rounded,
                            color: allOnline ? Colors.green : Colors.orange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mi zona', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              Text(
                                allOnline ? 'Todas las cámaras operando' : '$offline cámara(s) fuera de línea',
                                style: TextStyle(color: allOnline ? Colors.green : Colors.orange, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _MiniStat(icon: Icons.videocam, value: '$online', label: 'En línea', color: Colors.green),
                        const SizedBox(width: 16),
                        _MiniStat(icon: Icons.videocam_off, value: '$offline', label: 'Offline', color: Colors.grey),
                        const SizedBox(width: 16),
                        _MiniStat(icon: Icons.camera_alt, value: '${cameras.length}', label: 'Total', color: isDark ? Colors.white : AppColors.primaryBlue),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Card(child: Padding(padding: EdgeInsets.all(32), child: LoadingView(message: 'Cargando estado...'))),
      error: (e, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 12),
              const Expanded(child: Text('No se pudo cargar el estado de la zona')),
            ],
          ),
        ),
      ),
    );
  }

  /// Quick actions with gradient icons
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickActionData(Icons.videocam_rounded, 'Cámaras', [const Color(0xFF081221), const Color(0xFF8B5CF6)], () => context.go('/cameras')),
      _QuickActionData(Icons.report_problem_rounded, 'Reportar', [const Color(0xFFEF4444), const Color(0xFFF97316)], () => context.push('/create-incident')),
      _QuickActionData(Icons.map_rounded, 'Mapa', [const Color(0xFF10B981), const Color(0xFF34D399)], () => context.go('/map')),
      _QuickActionData(Icons.list_alt_rounded, 'Reportes', [const Color(0xFF00C6FF), const Color(0xFF06B6D4)], () => context.push('/my-reports')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Accesos rápidos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: actions.map((action) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: action != actions.last ? 8 : 0),
                child: _QuickActionButton(data: action),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Favorite cameras carousel
  Widget _buildFavoriteCameras(BuildContext context, AsyncValue<List<Camera>> camerasAsync, List<String> favoriteIds) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Cámaras favoritas', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => context.go('/cameras'),
              child: Text('Ver todas', style: TextStyle(color: isDark ? AppColors.accentCyan : AppColors.primaryBlue)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        camerasAsync.when(
          data: (cameras) {
            final favoriteCameras = cameras.where((c) => favoriteIds.contains(c.id) || c.isFavorite).toList();

            if (favoriteCameras.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.star_outline, size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      const Text('Sin cámaras favoritas'),
                      const SizedBox(height: 4),
                      Text('Marca cámaras como favoritas para verlas aquí',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }

            return SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: favoriteCameras.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final cam = favoriteCameras[index];
                  return _FavoriteCameraCard(camera: cam, onTap: () => context.push('/camera/${cam.id}'));
                },
              ),
            );
          },
          loading: () => const SizedBox(height: 130, child: Center(child: CircularProgressIndicator())),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Recent alerts with timeline dots
  Widget _buildRecentAlerts(BuildContext context, AsyncValue<List<Alert>> alertsAsync) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Alertas recientes', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => context.go('/alerts'),
              child: Text('Ver todas', style: TextStyle(color: isDark ? AppColors.accentCyan : AppColors.primaryBlue)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        alertsAsync.when(
          data: (alerts) {
            if (alerts.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline, size: 40, color: Colors.green.shade300),
                      const SizedBox(height: 8),
                      const Text('Sin alertas recientes'),
                      const SizedBox(height: 4),
                      Text('Todo tranquilo en tu zona', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: alerts.take(3).map((alert) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: theme.cardColor,
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => context.push('/alert/${alert.id}'),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                alert.priority.color.withValues(alpha: 0.2),
                                alert.priority.color.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(alert.type.icon, color: alert.priority.color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(alert.type.displayName,
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                              Text(alert.cameraName ?? 'Cámara desconocida',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: alert.status.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(alert.status.displayName,
                            style: TextStyle(fontSize: 11, color: alert.status.color, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ),
              )).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Error cargando alertas'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ========== Private Widgets ==========

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _MiniStat({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _QuickActionData {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _QuickActionData(this.icon, this.label, this.gradient, this.onTap);
}

class _QuickActionButton extends StatefulWidget {
  final _QuickActionData data;
  const _QuickActionButton({required this.data});

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
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
      onTapUp: (_) {
        _scaleCtrl.forward();
        widget.data.onTap();
      },
      onTapCancel: () => _scaleCtrl.forward(),
      child: ScaleTransition(
        scale: _scaleCtrl,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: widget.data.gradient[0].withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: widget.data.gradient),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.data.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 8),
              Text(widget.data.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteCameraCard extends StatelessWidget {
  final Camera camera;
  final VoidCallback onTap;
  const _FavoriteCameraCard({required this.camera, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 170,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: theme.cardColor,
            child: InkWell(
              onTap: onTap,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryBlue.withValues(alpha: 0.05),
                          AppColors.accentCyan.withValues(alpha: 0.08),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.videocam_rounded, size: 44, color: Colors.grey.shade300),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black87, Colors.transparent],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(camera.name,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 7, height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: camera.isOnline ? const Color(0xFF4CAF50) : Colors.red,
                                  boxShadow: camera.isOnline
                                      ? [BoxShadow(color: Colors.green.withValues(alpha: 0.5), blurRadius: 4)]
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(camera.isOnline ? 'En línea' : 'Offline',
                                style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    ),
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
