import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';

/// Confirmación de reporte enviado
class OperatorReportConfirmationScreen extends StatefulWidget {
  final String folio;
  const OperatorReportConfirmationScreen({super.key, required this.folio});

  @override
  State<OperatorReportConfirmationScreen> createState() => _OperatorReportConfirmationScreenState();
}

class _OperatorReportConfirmationScreenState extends State<OperatorReportConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success icon
                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.withValues(alpha: 0.15),
                          Colors.green.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade600,
                            Colors.green.shade400,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _fade,
                  child: Column(
                    children: [
                      Text('¡Reporte enviado!',
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Tu reporte ha sido registrado exitosamente',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      // Folio card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Text('Folio',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(widget.folio,
                                style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark ? AppColors.accentCyan : AppColors.primaryBlue,
                                    letterSpacing: 1.5)),
                            const SizedBox(height: 8),
                            Text('Registrado a las ${TimeOfDay.now().format(context)}',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Buttons
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/operator-report-detail/mock'),
                          icon: const Icon(Icons.visibility_rounded, size: 20),
                          label: const Text('Ver detalle del reporte'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => context.go('/operator-home'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Volver a inicio'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.go('/operator-report'),
                        child: const Text('Crear otro reporte'),
                      ),
                    ],
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
