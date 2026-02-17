import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/app_providers.dart';

/// Pantalla de selección de zona/colonia
class ZoneSelectionScreen extends ConsumerStatefulWidget {
  const ZoneSelectionScreen({super.key});

  @override
  ConsumerState<ZoneSelectionScreen> createState() =>
      _ZoneSelectionScreenState();
}

class _ZoneSelectionScreenState extends ConsumerState<ZoneSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedZone;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Zonas mock para el MVP
  final List<_ZoneData> _zones = const [
    _ZoneData(
      name: 'Centro Histórico',
      cameras: 12,
      icon: Icons.location_city_rounded,
    ),
    _ZoneData(
      name: 'Colonia Residencial Norte',
      cameras: 8,
      icon: Icons.home_rounded,
    ),
    _ZoneData(
      name: 'Zona Industrial',
      cameras: 15,
      icon: Icons.factory_rounded,
    ),
    _ZoneData(
      name: 'Fraccionamiento Las Palmas',
      cameras: 6,
      icon: Icons.park_rounded,
    ),
    _ZoneData(
      name: 'Colonia San Miguel',
      cameras: 10,
      icon: Icons.apartment_rounded,
    ),
    _ZoneData(
      name: 'Parque Empresarial Sur',
      cameras: 9,
      icon: Icons.business_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _selectAndContinue() async {
    if (_selectedZone == null) return;
    final storage = ref.read(localStorageProvider);
    await storage.setSelectedZone(_selectedZone!);
    if (mounted) {
      context.go('/welcome');
    }
  }

  void _skip() {
    context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.accentCyan],
                    ),
                  ),
                  child: const Icon(
                    Icons.map_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Selecciona tu zona',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Elige tu zona o colonia para ver las cámaras y alertas de tu comunidad.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 24),

                // Zone list
                Expanded(
                  child: ListView.separated(
                    itemCount: _zones.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final zone = _zones[index];
                      final isSelected = _selectedZone == zone.name;
                      return _ZoneCard(
                        zone: zone,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => _selectedZone = zone.name);
                        },
                        index: index,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),
                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedZone != null ? _selectAndContinue : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.primaryBlue.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: _selectedZone != null ? 3 : 0,
                    ),
                    child: const Text(
                      'Seleccionar zona',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: _skip,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue.withOpacity(0.7),
                    ),
                    child: const Text('Saltar por ahora'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ZoneCard extends StatefulWidget {
  final _ZoneData zone;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  const _ZoneCard({
    required this.zone,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });

  @override
  State<_ZoneCard> createState() => _ZoneCardState();
}

class _ZoneCardState extends State<_ZoneCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    Future.delayed(Duration(milliseconds: 100 + (widget.index * 80)), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          child: Card(
            elevation: widget.isSelected ? 4 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: widget.isSelected
                  ? const BorderSide(color: AppColors.primaryBlue, width: 2)
                  : BorderSide.none,
            ),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: widget.isSelected
                            ? AppColors.primaryBlue
                            : AppColors.primaryBlue.withOpacity(0.1),
                      ),
                      child: Icon(
                        widget.zone.icon,
                        color: widget.isSelected
                            ? Colors.white
                            : AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.zone.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.zone.cameras} cámaras activas',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.accentCyan,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isSelected)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.primaryBlue),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ZoneData {
  final String name;
  final int cameras;
  final IconData icon;

  const _ZoneData({
    required this.name,
    required this.cameras,
    required this.icon,
  });
}
