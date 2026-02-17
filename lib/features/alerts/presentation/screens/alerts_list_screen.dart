import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/alert_providers.dart';
import '../widgets/alert_card.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../domain/enums/alert_status.dart';
import '../../../../app/theme/app_colors.dart';

/// Pantalla de lista de alertas con tabs — Premium
class AlertsListScreen extends ConsumerStatefulWidget {
  const AlertsListScreen({super.key});

  @override
  ConsumerState<AlertsListScreen> createState() => _AlertsListScreenState();
}

class _AlertsListScreenState extends ConsumerState<AlertsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<AlertStatus?> _tabs = [
    null, // Todas
    AlertStatus.pending,
    AlertStatus.reviewing,
    AlertStatus.confirmed,
    AlertStatus.resolved,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.accentCyan],
            ),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          dividerColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((status) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(status?.displayName ?? 'Todas'),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs
            .map((status) => _AlertsList(statusFilter: status?.name))
            .toList(),
      ),
    );
  }
}

class _AlertsList extends ConsumerWidget {
  final String? statusFilter;

  const _AlertsList({this.statusFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(filteredAlertsProvider(statusFilter));

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(alertsProvider),
      child: alertsAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return const EmptyView(
              message: 'No hay alertas',
              icon: Icons.notifications_off_outlined,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 400 + (index * 60)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                ),
                child: AlertCard(alert: alerts[index]),
              );
            },
          );
        },
        loading: () => const LoadingView(message: 'Cargando alertas...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(alertsProvider),
        ),
      ),
    );
  }
}
