import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/chip_status.dart';

/// Detalle de notificación / incidente recibido
class OperatorNotificationDetailScreen extends StatelessWidget {
  final String notificationId;
  const OperatorNotificationDetailScreen({super.key, required this.notificationId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Mock: simular si es pánico
    final isPanic = notificationId == '2';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isPanic ? Colors.red.shade700 : null,
        foregroundColor: isPanic ? Colors.white : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tipo + urgencia
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isPanic
                  ? Colors.red.withValues(alpha: 0.06)
                  : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPanic
                    ? Colors.red.withValues(alpha: 0.3)
                    : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isPanic ? Colors.red.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isPanic ? Icons.emergency_rounded : Icons.warning_amber_rounded,
                        color: isPanic ? Colors.red : Colors.orange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPanic ? 'Alerta de pánico' : 'Incidente: Sospechoso',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              ChipStatus(
                                label: isPanic ? 'Pánico' : 'Media',
                                color: isPanic ? Colors.red : const Color(0xFFFFA726),
                                icon: isPanic ? Icons.emergency : Icons.remove_rounded,
                              ),
                              const SizedBox(width: 8),
                              Text('Zona A', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text('Hoy 14:30 — Hace 10 min',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Descripción
          _buildCard(
            theme,
            isDark,
            icon: Icons.description_rounded,
            iconColor: isDark ? AppColors.accentCyan : AppColors.primaryBlue,
            title: 'Descripción',
            child: Text(
              isPanic
                  ? 'Un operador ha activado la alerta de pánico desde Zona C. Se requiere atención inmediata.'
                  : 'Se observó a una persona sospechosa merodeando por la entrada principal del fraccionamiento. Revisaba vehículos estacionados.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
          const SizedBox(height: 16),

          // Ubicación
          _buildCard(
            theme,
            isDark,
            icon: Icons.location_on_rounded,
            iconColor: Colors.green,
            title: 'Ubicación',
            child: Column(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_rounded, size: 32, color: Colors.grey.shade400),
                        const SizedBox(height: 4),
                        Text('19.4326° N, 99.1332° W',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: Text(isPanic ? 'Ver ubicación en mapa' : 'Abrir mapa',
                        style: const TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isPanic ? Colors.red : null,
                      side: isPanic ? const BorderSide(color: Colors.red) : null,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Evidencias (si hay)
          if (!isPanic)
            _buildCard(
              theme,
              isDark,
              icon: Icons.photo_library_rounded,
              iconColor: Colors.deepPurple,
              title: 'Evidencias (1)',
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(Icons.camera_alt_rounded, color: Colors.grey.shade400, size: 28),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (!isPanic) const SizedBox(height: 16),

          // Botones de acción
          if (isPanic)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.warning_rounded, color: Colors.red, size: 36),
                  const SizedBox(height: 8),
                  const Text('¡ALERTA DE PÁNICO ACTIVA!',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  const SizedBox(height: 4),
                  Text('Un operador necesita ayuda urgente',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.location_on_rounded, size: 18),
                      label: const Text('Ver ubicación en mapa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Botones generales
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Marcado como visto')),
                    );
                  },
                  icon: const Icon(Icons.visibility_rounded, size: 18),
                  label: const Text('Marcar visto', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Estás al pendiente')),
                    );
                  },
                  icon: const Icon(Icons.thumb_up_alt_outlined, size: 18),
                  label: const Text('Al pendiente', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCard(
    ThemeData theme,
    bool isDark, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
