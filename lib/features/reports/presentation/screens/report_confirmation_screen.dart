import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de confirmación después de enviar un reporte
class ReportConfirmationScreen extends StatelessWidget {
  final String folio;
  const ReportConfirmationScreen({super.key, required this.folio});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Ícono de éxito
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
              ),

              const SizedBox(height: 32),

              Text(
                '¡Reporte enviado!',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Tu reporte ha sido recibido y está en proceso de revisión.',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Folio
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Text('Folio de seguimiento', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(
                      folio,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('En revisión', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Guarda este folio para dar seguimiento a tu reporte.',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Botones
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.push('/my-reports'),
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Ver mis reportes'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Volver al inicio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
