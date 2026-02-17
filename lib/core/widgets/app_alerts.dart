import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

/// Tipos de alerta premium
enum AlertType { success, error, warning, info }

/// Helper para mostrar alertas premium (SnackBar y Dialog) en la app.
class AppAlerts {
  AppAlerts._();

  // ====== SnackBar Premium ======

  /// Muestra un SnackBar premium con ícono, gradiente y animación.
  static void showSnackBar(
    BuildContext context, {
    required String message,
    String? title,
    AlertType type = AlertType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();

    final config = _getConfig(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícono con fondo circular
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(config.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  if (title != null) const SizedBox(height: 2),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: config.color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: duration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  // ====== Dialog Premium ======

  /// Muestra un diálogo premium con ícono animado y botones estilizados.
  static Future<bool?> showAlertDialog(
    BuildContext context, {
    required String title,
    required String message,
    AlertType type = AlertType.info,
    String confirmText = 'Aceptar',
    String? cancelText,
    VoidCallback? onConfirm,
  }) {
    final config = _getConfig(type);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim, secondaryAnim, child) {
        final curve = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curve,
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      pageBuilder: (context, anim, secondaryAnim) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E30) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: config.color.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícono con fondo gradiente
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [config.color, config.colorLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: config.color.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(config.icon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 20),
                  // Título
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Mensaje
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : AppColors.grey600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Botones
                  Row(
                    children: [
                      if (cancelText != null) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: BorderSide(
                                color: isDark ? Colors.white24 : AppColors.grey300,
                              ),
                            ),
                            child: Text(
                              cancelText,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : AppColors.grey600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                            onConfirm?.call();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: config.color,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: config.color.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            confirmText,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ====== Config interna ======

  static _AlertConfig _getConfig(AlertType type) {
    switch (type) {
      case AlertType.success:
        return _AlertConfig(
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF10B981),
          colorLight: const Color(0xFF34D399),
        );
      case AlertType.error:
        return _AlertConfig(
          icon: Icons.error_rounded,
          color: const Color(0xFFEF4444),
          colorLight: const Color(0xFFF87171),
        );
      case AlertType.warning:
        return _AlertConfig(
          icon: Icons.warning_rounded,
          color: const Color(0xFFF59E0B),
          colorLight: const Color(0xFFFBBF24),
        );
      case AlertType.info:
        return _AlertConfig(
          icon: Icons.info_rounded,
          color: AppColors.primaryBlue,
          colorLight: AppColors.accentCyan,
        );
    }
  }
}

class _AlertConfig {
  final IconData icon;
  final Color color;
  final Color colorLight;

  _AlertConfig({
    required this.icon,
    required this.color,
    required this.colorLight,
  });
}
