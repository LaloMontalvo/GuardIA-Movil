import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/camera.dart';
import '../../domain/repositories/camera_repository.dart';
import '../../data/repositories/camera_repository_impl.dart';
import '../../../../core/di/providers.dart';

// ========== Repository Provider ==========

final cameraRepositoryProvider = Provider<CameraRepository>((ref) {
  return CameraRepositoryImpl(ref.watch(dioClientProvider));
});

// ========== Cameras List Provider ==========

final camerasProvider = FutureProvider<List<Camera>>((ref) async {
  return await ref.watch(cameraRepositoryProvider).getCameras();
});

// ========== Camera Detail Provider ==========

final cameraDetailProvider = FutureProvider.family<Camera, String>((ref, id) async {
  return await ref.watch(cameraRepositoryProvider).getCameraDetail(id);
});

// ========== Search Query Provider ==========

final cameraSearchQueryProvider = StateProvider<String>((ref) => '');

// ========== Filtered Cameras Provider ==========

final filteredCamerasProvider = Provider<AsyncValue<List<Camera>>>((ref) {
  final camerasAsync = ref.watch(camerasProvider);
  final searchQuery = ref.watch(cameraSearchQueryProvider);

  return camerasAsync.when(
    data: (cameras) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(cameras);
      }

      final filtered = cameras.where((camera) {
        return camera.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               camera.location.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
