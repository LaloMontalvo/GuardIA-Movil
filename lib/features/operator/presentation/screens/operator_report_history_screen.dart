import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/chip_status.dart';

/// Historial de reportes del Operador con filtros
class OperatorReportHistoryScreen extends StatefulWidget {
  const OperatorReportHistoryScreen({super.key});

  @override
  State<OperatorReportHistoryScreen> createState() => _OperatorReportHistoryScreenState();
}

class _OperatorReportHistoryScreenState extends State<OperatorReportHistoryScreen> {
  String _filterDate = 'Todos';
  String _filterStatus = 'Todos';
  String _filterUrgency = 'Todos';

  final _mockReports = [
    _Report('RPT-001', 'Sospechoso', 'Persona merodeando', 'Hoy 14:30', 'enviado', 'media', true),
    _Report('RPT-002', 'Ruido', 'Ruido excesivo Zona B', 'Ayer 22:15', 'en revisión', 'baja', false),
    _Report('RPT-003', 'Accidente', 'Choque menor Av. Principal', '15/03/2026', 'cerrado', 'alta', true),
    _Report('RPT-004', 'Vandalismo', 'Grafiti en pared', '14/03/2026', 'cerrado', 'baja', false),
    _Report('RPT-005', 'Sospechoso', 'Vehículo estacionado', '12/03/2026', 'cerrado', 'media', true),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reportes', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: _filterDate == 'Todos' ? 'Fecha' : _filterDate,
                    icon: Icons.calendar_today_rounded,
                    isActive: _filterDate != 'Todos',
                    onTap: () => _showFilterSheet('date'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: _filterStatus == 'Todos' ? 'Estado' : _filterStatus,
                    icon: Icons.check_circle_outline,
                    isActive: _filterStatus != 'Todos',
                    onTap: () => _showFilterSheet('status'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: _filterUrgency == 'Todos' ? 'Urgencia' : _filterUrgency,
                    icon: Icons.priority_high_rounded,
                    isActive: _filterUrgency != 'Todos',
                    onTap: () => _showFilterSheet('urgency'),
                  ),
                  if (_filterDate != 'Todos' || _filterStatus != 'Todos' || _filterUrgency != 'Todos') ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() {
                        _filterDate = 'Todos';
                        _filterStatus = 'Todos';
                        _filterUrgency = 'Todos';
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.clear_all_rounded, color: Colors.red, size: 18),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _mockReports.length,
              itemBuilder: (context, index) {
                final report = _mockReports[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 350 + (index * 50)),
                  curve: Curves.easeOutCubic,
                  builder: (ctx, v, child) => Opacity(
                    opacity: v,
                    child: Transform.translate(offset: Offset(0, 15 * (1 - v)), child: child),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: theme.cardColor,
                      border: Border.all(color: theme.dividerColor.withValues(alpha: 0.08)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            _getTypeColor(report.type).withValues(alpha: 0.15),
                            _getTypeColor(report.type).withValues(alpha: 0.05),
                          ]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: report.hasEvidence
                            ? Stack(
                                children: [
                                  Center(
                                    child: Icon(Icons.image_rounded, color: Colors.grey.shade400, size: 24),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 2,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: _getTypeColor(report.type),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(Icons.attach_file, color: Colors.white, size: 10),
                                    ),
                                  ),
                                ],
                              )
                            : Icon(_getTypeIcon(report.type), color: _getTypeColor(report.type), size: 22),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(report.type,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                          _buildStatusChip(report.status),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Text(report.folio,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                            const SizedBox(width: 8),
                            Text('•', style: TextStyle(color: Colors.grey.shade400)),
                            const SizedBox(width: 8),
                            Text(report.date,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      onTap: () => context.push('/operator-report-detail/${report.folio}'),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    switch (status) {
      case 'enviado':
        return ChipStatus.enviado();
      case 'en revisión':
        return ChipStatus.enRevision();
      case 'cerrado':
        return ChipStatus.cerrado();
      default:
        return ChipStatus(label: status, color: Colors.grey);
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Sospechoso': return Colors.orange;
      case 'Ruido': return Colors.purple;
      case 'Accidente': return Colors.red;
      case 'Vandalismo': return Colors.deepOrange;
      default: return AppColors.primaryBlue;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Sospechoso': return Icons.person_search_rounded;
      case 'Ruido': return Icons.volume_up_rounded;
      case 'Accidente': return Icons.car_crash_rounded;
      case 'Vandalismo': return Icons.format_paint_rounded;
      default: return Icons.report_problem_rounded;
    }
  }

  void _showFilterSheet(String filterType) {
    final options = switch (filterType) {
      'date' => ['Todos', 'Hoy', 'Esta semana', 'Este mes'],
      'status' => ['Todos', 'Enviado', 'En revisión', 'Cerrado'],
      'urgency' => ['Todos', 'Baja', 'Media', 'Alta'],
      _ => <String>[],
    };

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ...options.map((option) => ListTile(
                  title: Text(option),
                  trailing: _isFilterSelected(filterType, option)
                      ? const Icon(Icons.check_circle, color: AppColors.primaryBlue)
                      : null,
                  onTap: () {
                    setState(() {
                      switch (filterType) {
                        case 'date': _filterDate = option;
                        case 'status': _filterStatus = option;
                        case 'urgency': _filterUrgency = option;
                      }
                    });
                    Navigator.pop(ctx);
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                )),
          ],
        ),
      ),
    );
  }

  bool _isFilterSelected(String filterType, String option) {
    return switch (filterType) {
      'date' => _filterDate == option,
      'status' => _filterStatus == option,
      'urgency' => _filterUrgency == option,
      _ => false,
    };
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue).withValues(alpha: 0.12)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? (isDark ? AppColors.accentCyan : AppColors.primaryBlue)
                : Theme.of(context).dividerColor.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14,
                color: isActive
                    ? (isDark ? AppColors.accentCyan : AppColors.primaryBlue)
                    : Colors.grey),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive
                      ? (isDark ? AppColors.accentCyan : AppColors.primaryBlue)
                      : Colors.grey.shade600,
                )),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 16,
                color: isActive
                    ? (isDark ? AppColors.accentCyan : AppColors.primaryBlue)
                    : Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _Report {
  final String folio, type, description, date, status, urgency;
  final bool hasEvidence;
  const _Report(this.folio, this.type, this.description, this.date, this.status, this.urgency, this.hasEvidence);
}
