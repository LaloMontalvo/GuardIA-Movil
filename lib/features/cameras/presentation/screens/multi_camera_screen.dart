import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/camera_providers.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/error_view.dart';

/// Vista mosaico multi-cámara
class MultiCameraScreen extends ConsumerWidget {
  const MultiCameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camerasAsync = ref.watch(camerasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Cámara'),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.grid_view),
            onSelected: (value) {},
            itemBuilder: (context) => [
              const PopupMenuItem(value: 4, child: Text('2x2')),
              const PopupMenuItem(value: 6, child: Text('2x3')),
              const PopupMenuItem(value: 9, child: Text('3x3')),
            ],
          ),
        ],
      ),
      body: camerasAsync.when(
        data: (cameras) {
          final onlineCameras = cameras.where((c) => c.isOnline).toList();
          
          if (onlineCameras.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay cámaras en línea'),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 16 / 9,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: onlineCameras.length > 9 ? 9 : onlineCameras.length,
            itemBuilder: (context, index) {
              final camera = onlineCameras[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to live view
                  Navigator.of(context).pushNamed('/camera/${camera.id}/live');
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.videocam,
                          color: Colors.white.withOpacity(0.3),
                          size: 40,
                        ),
                      ),
                      // Camera name overlay
                      Positioned(
                        left: 8,
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            camera.name,
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      // Live indicator
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, color: Colors.white, size: 8),
                              SizedBox(width: 4),
                              Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingView(message: 'Cargando cámaras...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(camerasProvider),
        ),
      ),
    );
  }
}
