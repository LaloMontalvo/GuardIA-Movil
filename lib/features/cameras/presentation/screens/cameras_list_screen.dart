import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/camera_providers.dart';
import '../widgets/camera_card.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../domain/enums/camera_status.dart';
import '../../../../app/theme/app_colors.dart';

/// Pantalla de lista de cámaras con búsqueda y filtros — Premium
class CamerasListScreen extends ConsumerStatefulWidget {
  const CamerasListScreen({super.key});

  @override
  ConsumerState<CamerasListScreen> createState() => _CamerasListScreenState();
}

class _CamerasListScreenState extends ConsumerState<CamerasListScreen>
    with SingleTickerProviderStateMixin {
  CameraStatus? _selectedStatus;
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCamerasAsync = ref.watch(filteredCamerasProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cámaras', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list_rounded),
              color: isDark ? AppColors.accentCyan : AppColors.primaryBlue,
              onPressed: _showFilterDialog,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o ubicación...',
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.white70 : AppColors.primaryBlue.withValues(alpha: 0.6)),
                  filled: false,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) {
                  ref.read(cameraSearchQueryProvider.notifier).state = value;
                },
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          if (_selectedStatus != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: FilterChip(
                      label: Text(_selectedStatus!.displayName),
                      onSelected: (_) => setState(() => _selectedStatus = null),
                      selected: true,
                      selectedColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                      checkmarkColor: isDark ? AppColors.accentCyan : AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => setState(() => _selectedStatus = null),
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Limpiar'),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  ),
                ],
              ),
            ),

          // Camera list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(camerasProvider),
              child: filteredCamerasAsync.when(
                data: (cameras) {
                  var displayCameras = cameras;
                  if (_selectedStatus != null) {
                    displayCameras = cameras.where((c) => c.status == _selectedStatus).toList();
                  }

                  if (displayCameras.isEmpty) {
                    return const EmptyView(
                      message: 'No se encontraron cámaras',
                      icon: Icons.videocam_off_outlined,
                    );
                  }

                  return FadeTransition(
                    opacity: CurvedAnimation(parent: _listController, curve: Curves.easeOut),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: displayCameras.length,
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
                          child: CameraCard(camera: displayCameras[index]),
                        );
                      },
                    ),
                  );
                },
                loading: () => const LoadingView(message: 'Cargando cámaras...'),
                error: (error, _) => ErrorView(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(camerasProvider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Filtrar por estado',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _FilterOption(
              title: 'Todas',
              icon: Icons.list_rounded,
              isSelected: _selectedStatus == null,
              onTap: () {
                setState(() => _selectedStatus = null);
                Navigator.pop(context);
              },
            ),
            ...CameraStatus.values.map(
              (status) => _FilterOption(
                title: status.displayName,
                icon: status.icon,
                color: status.color,
                isSelected: _selectedStatus == status,
                onTap: () {
                  setState(() => _selectedStatus = status);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.title,
    required this.icon,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.08) : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? (isSelected ? AppColors.primaryBlue : Colors.grey)),
        title: Text(title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppColors.primaryBlue : null,
            )),
        trailing: isSelected
            ? Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue)
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
