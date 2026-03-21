import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/camera_providers.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../app/theme/app_colors.dart';

/// Pantalla de detalle de cámara — Premium
class CameraDetailScreen extends ConsumerStatefulWidget {
  final String cameraId;

  const CameraDetailScreen({super.key, required this.cameraId});

  @override
  ConsumerState<CameraDetailScreen> createState() => _CameraDetailScreenState();
}

class _CameraDetailScreenState extends ConsumerState<CameraDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  Widget _stagger(int index, Widget child) {
    final start = (index * 0.12).clamp(0.0, 0.7);
    final end = (start + 0.4).clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: _staggerCtrl,
      builder: (context, _) {
        final fade = Tween<double>(begin: 0, end: 1)
            .animate(CurvedAnimation(parent: _staggerCtrl, curve: Interval(start, end, curve: Curves.easeOut)));
        final slide = Tween<Offset>(begin: const Offset(0, 20), end: Offset.zero)
            .animate(CurvedAnimation(parent: _staggerCtrl, curve: Interval(start, end, curve: Curves.easeOutCubic)));
        return Opacity(
          opacity: fade.value,
          child: Transform.translate(offset: slide.value, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cameraAsync = ref.watch(cameraDetailProvider(widget.cameraId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return cameraAsync.when(
      data: (camera) => Scaffold(
        body: CustomScrollView(
          slivers: [
            // Gradient App Bar
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(camera.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    )),
                background: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A3E) : AppColors.primaryBlue,
                  ),
                  child: Center(
                    child: Icon(Icons.videocam_rounded, size: 64,
                        color: Colors.white.withValues(alpha: 0.2)),
                  ),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: Icon(
                      camera.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: camera.isFavorite ? Colors.amber : Colors.white,
                    ),
                    onPressed: () {
                      // TODO: Implement favorite toggle when state management supports it
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(camera.isFavorite ? 'Removido de favoritos' : 'Agregado a favoritos')),
                      );
                    },
                  ),
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Status bar
                  _stagger(0, Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: camera.isOnline
                            ? [Colors.green.withValues(alpha: 0.08), Colors.green.withValues(alpha: 0.02)]
                            : [Colors.red.withValues(alpha: 0.08), Colors.red.withValues(alpha: 0.02)],
                      ),
                      border: Border.all(
                        color: (camera.isOnline ? Colors.green : Colors.red).withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12, height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: camera.isOnline ? Colors.green : Colors.red,
                            boxShadow: camera.isOnline
                                ? [BoxShadow(color: Colors.green.withValues(alpha: 0.4), blurRadius: 6)]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          camera.isOnline ? 'En línea' : 'Fuera de línea',
                          style: TextStyle(
                            color: camera.isOnline ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(camera.status.displayName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: camera.status.color,
                              fontWeight: FontWeight.w500,
                            )),
                      ],
                    ),
                  )),
                  const SizedBox(height: 16),

                  // Info cards
                  _stagger(1, _InfoCard(
                    items: [
                      _InfoRow(Icons.location_on_outlined, 'Ubicación', camera.location),
                      _InfoRow(Icons.map_outlined, 'Zona', camera.zone),
                      _InfoRow(Icons.tag, 'ID', camera.id),
                    ],
                  )),
                  const SizedBox(height: 16),

                  // Live view button
                  _stagger(2, Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.primaryBlue,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => context.push('/camera/${camera.id}/live'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              const Text('Ver en Vivo',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
                  const SizedBox(height: 16),

                  // Quick actions
                  _stagger(3, Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.video_library_outlined,
                          label: 'Grabaciones',
                          color: const Color(0xFFF97316),
                          onTap: () => context.push('/recordings'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.settings_outlined,
                          label: 'Configurar',
                          color: Colors.grey,
                          onTap: () {},
                        ),
                      ),
                    ],
                  )),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Cámara')),
        body: const LoadingView(message: 'Cargando detalles...'),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Cámara')),
        body: ErrorView(message: e.toString()),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.icon, size: 18, color: isDark ? Colors.white : AppColors.primaryBlue),
                    ),
                    const SizedBox(width: 12),
                    Text(item.label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                    const Spacer(),
                    Flexible(
                      child: Text(item.value,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < items.length - 1)
                Divider(height: 1, indent: 56, color: theme.dividerColor.withValues(alpha: 0.08)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
