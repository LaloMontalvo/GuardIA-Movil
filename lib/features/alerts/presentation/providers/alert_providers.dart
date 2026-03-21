import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../data/repositories/alert_repository_impl.dart';
import '../../../../core/di/providers.dart';

// ========== Repository Provider ==========

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return AlertRepositoryImpl(ref.watch(dioClientProvider));
});

// ========== Alerts List Provider ==========

final alertsProvider = FutureProvider<List<Alert>>((ref) async {
  return await ref.watch(alertRepositoryProvider).getAlerts();
});

// ========== Alert Detail Provider ==========

final alertDetailProvider = FutureProvider.family<Alert, String>((ref, id) async {
  return await ref.watch(alertRepositoryProvider).getAlertDetail(id);
});

// ========== Filtered Alerts Provider (by status) ==========

final filteredAlertsProvider = Provider.family<AsyncValue<List<Alert>>, String?>((ref, status) {
  final alertsAsync = ref.watch(alertsProvider);

  return alertsAsync.when(
    data: (alerts) {
      if (status == null || status.isEmpty) {
        return AsyncValue.data(alerts);
      }

      final filtered = alerts.where((alert) => alert.status.name == status).toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
