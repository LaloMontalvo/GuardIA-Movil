import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/chip_status.dart';

class OperatorHomeScreen extends ConsumerStatefulWidget {
  const OperatorHomeScreen({super.key});

  @override
  ConsumerState<OperatorHomeScreen> createState() => _OperatorHomeScreenState();
}

class _OperatorHomeScreenState extends ConsumerState<OperatorHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _staggerController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  final List<Animation<double>> _itemFades = [];
  final List<Animation<Offset>> _itemSlides = [];
  static const _itemCount = 4;

  bool _locationSharing = false;

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
      duration: const Duration(milliseconds: 1400),
    );

    for (int i = 0; i < _itemCount; i++) {
      final start = i * 0.12;
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
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh data
        },
        child: CustomScrollView(
          slivers: [
            // Header
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
                                  'Hola, ${user?.name ?? "Operador"}',
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
                  // 1. Tarjeta de estado
                  _animatedItem(0, _buildStatusCard(context)),
                  const SizedBox(height: 20),

                  // 2. Acciones rápidas
                  _animatedItem(1, _buildQuickActions(context)),
                  const SizedBox(height: 20),

                  // 3. Avisos recientes
                  _animatedItem(2, _buildRecentNotifications(context)),
                  const SizedBox(height: 20),

                  // 4. Mis reportes recientes
                  _animatedItem(3, _buildMyRecentReports(context)),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationBell(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => context.go('/operator-notifications'),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días — mantén tu zona segura';
    if (hour < 18) return 'Buenas tardes — todo en orden';
    return 'Buenas noches — vigilancia activa';
  }

  /// Tarjeta de estado de conexión/ubicación/notificaciones
  Widget _buildStatusCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF43A047),
            const Color(0xFF66BB6A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.shield_rounded, color: Colors.green, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text('Estado del sistema',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              _StatusRow(
                icon: Icons.wifi_rounded,
                label: 'Conexión',
                value: 'Conectado',
                color: Colors.green,
              ),
              const SizedBox(height: 8),
              _StatusRow(
                icon: Icons.location_on_rounded,
                label: 'Ubicación',
                value: 'Activa',
                color: Colors.green,
              ),
              const SizedBox(height: 8),
              _StatusRow(
                icon: Icons.notifications_active_rounded,
                label: 'Notificaciones',
                value: 'Activadas',
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Verificando permisos...')),
                    );
                  },
                  icon: const Icon(Icons.verified_user_outlined, size: 16),
                  label: const Text('Revisar permisos', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? AppColors.accentCyan : AppColors.primaryBlue,
                    side: BorderSide(color: (isDark ? AppColors.accentCyan : AppColors.primaryBlue).withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Acciones rápidas — cards grandes
  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Acciones rápidas',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        // Row 1: Crear reporte + Pánico
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.add_circle_outline_rounded,
                label: 'Crear reporte',
                gradientColors: const [AppColors.primaryBlue, Color(0xFF8B5CF6)],
                onTap: () => context.go('/operator-report'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.emergency_rounded,
                label: '🚨 PÁNICO',
                gradientColors: const [Color(0xFFE53935), Color(0xFFFF5252)],
                isDanger: true,
                onTap: () => context.push('/operator-panic'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Row 2: Compartir ubicación + Mi cámara
        Row(
          children: [
            Expanded(
              child: _LocationToggleCard(
                isActive: _locationSharing,
                onToggle: () {
                  setState(() => _locationSharing = !_locationSharing);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_locationSharing
                          ? 'Compartiendo ubicación en vivo'
                          : 'Ubicación en vivo desactivada'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.videocam_rounded,
                label: 'Mi Cámara',
                gradientColors: const [Color(0xFF10B981), Color(0xFF34D399)],
                onTap: () => context.go('/operator-camera'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Avisos recientes
  Widget _buildRecentNotifications(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final mockNotifs = [
      _MockNotif('Sospechoso', 'Persona merodeando', 'Hace 10 min', '~200m', true),
      _MockNotif('Ruido', 'Ruido excesivo Zona B', 'Hace 25 min', '~500m', false),
      _MockNotif('Accidente', 'Choque menor Av. Principal', 'Hace 1h', '~1km', false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Avisos recientes',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => context.go('/operator-notifications'),
              child: Text('Ver todos',
                  style: TextStyle(color: isDark ? AppColors.accentCyan : AppColors.primaryBlue)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...mockNotifs.map((notif) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: theme.cardColor,
                border: Border.all(
                    color: notif.isNew
                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                        : theme.dividerColor.withValues(alpha: 0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.orange.withValues(alpha: 0.15),
                      Colors.orange.withValues(alpha: 0.05),
                    ]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                ),
                title: Text(notif.type,
                    style: TextStyle(
                        fontWeight: notif.isNew ? FontWeight.bold : FontWeight.w500, fontSize: 14)),
                subtitle: Text('${notif.description} • ${notif.distance}',
                    style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(notif.time,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey.shade500, fontSize: 11)),
                    if (notif.isNew) ...[
                      const SizedBox(height: 4),
                      const ChipStatus(label: 'Nuevo', color: Color(0xFFE53935)),
                    ],
                  ],
                ),
                onTap: () => context.push('/operator-notification-detail/mock'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            )),
      ],
    );
  }

  /// Mis reportes recientes
  Widget _buildMyRecentReports(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final mockReports = [
      _MockReport('Sospechoso', 'Hoy 14:30', 'enviado'),
      _MockReport('Ruido excesivo', 'Ayer 22:15', 'en revisión'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Mis reportes recientes',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => context.push('/operator-report-history'),
              child: Text('Ver todos',
                  style: TextStyle(color: isDark ? AppColors.accentCyan : AppColors.primaryBlue)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...mockReports.map((report) => Container(
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
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppColors.primaryBlue.withValues(alpha: 0.15),
                      AppColors.accentCyan.withValues(alpha: 0.05),
                    ]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.description_rounded,
                      color: isDark ? AppColors.accentCyan : AppColors.primaryBlue, size: 20),
                ),
                title: Text(report.type,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(report.date, style: const TextStyle(fontSize: 12)),
                trailing: ChipStatus(
                  label: report.status == 'enviado' ? 'Enviado' : 'En revisión',
                  color: report.status == 'enviado'
                      ? const Color(0xFF2196F3)
                      : const Color(0xFFFFA726),
                  icon: report.status == 'enviado'
                      ? Icons.send_rounded
                      : Icons.hourglass_top_rounded,
                ),
                onTap: () => context.push('/operator-report-detail/mock'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            )),
      ],
    );
  }
}

// ========== Private Widgets ==========

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatusRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final bool isDanger;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard>
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
        widget.onTap();
      },
      onTapCancel: () => _scaleCtrl.forward(),
      child: ScaleTransition(
        scale: _scaleCtrl,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: widget.isDanger
                ? LinearGradient(colors: widget.gradientColors)
                : null,
            color: widget.isDanger ? null : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: widget.isDanger
                ? null
                : Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors[0].withValues(alpha: widget.isDanger ? 0.3 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: widget.isDanger
                      ? null
                      : LinearGradient(colors: widget.gradientColors),
                  color: widget.isDanger ? Colors.white.withValues(alpha: 0.2) : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: widget.isDanger ? Colors.white : null,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationToggleCard extends StatelessWidget {
  final bool isActive;
  final VoidCallback onToggle;
  const _LocationToggleCard({required this.isActive, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.withValues(alpha: 0.08) : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? Colors.green.withValues(alpha: 0.3)
                : theme.dividerColor.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: (isActive ? Colors.green : Colors.black).withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.location_on_rounded : Icons.location_off_rounded,
              color: isActive ? Colors.green : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              isActive ? 'Compartiendo\nubicación' : 'Ubicación\ndesactivada',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.green : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MockNotif {
  final String type, description, time, distance;
  final bool isNew;
  const _MockNotif(this.type, this.description, this.time, this.distance, this.isNew);
}

class _MockReport {
  final String type, date, status;
  const _MockReport(this.type, this.date, this.status);
}
