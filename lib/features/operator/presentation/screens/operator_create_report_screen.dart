import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/media_picker_sheet.dart';

/// Crear Reporte — Formulario completo de incidente
class OperatorCreateReportScreen extends StatefulWidget {
  const OperatorCreateReportScreen({super.key});

  @override
  State<OperatorCreateReportScreen> createState() => _OperatorCreateReportScreenState();
}

class _OperatorCreateReportScreenState extends State<OperatorCreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedType;
  int _urgencyIndex = 0; // 0=Baja, 1=Media, 2=Alta
  final _descController = TextEditingController();
  final List<String> _evidences = [];
  bool _shareLocation = true;
  bool _notifyZoneOnly = true;
  bool _isSending = false;

  final _incidentTypes = [
    'Robo',
    'Sospechoso',
    'Accidente',
    'Ruido',
    'Incendio',
    'Vandalismo',
    'Otro',
  ];

  final _urgencyLabels = ['Baja', 'Media', 'Alta'];
  final _urgencyColors = [
    const Color(0xFF2196F3),
    const Color(0xFFFFA726),
    const Color(0xFFE53935),
  ];
  final _urgencyIcons = [
    Icons.arrow_downward_rounded,
    Icons.remove_rounded,
    Icons.arrow_upward_rounded,
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _addEvidence() async {
    final result = await MediaPickerSheet.show(context);
    if (result != null) {
      setState(() {
        _evidences.add(result.name);
      });
    }
  }

  void _submitReport() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un tipo de incidente')),
      );
      return;
    }

    setState(() => _isSending = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.pushReplacement('/operator-report-confirmation/RPT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
      }
    });
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Borrador guardado')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Reporte', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _saveDraft,
            child: Text('Borrador',
                style: TextStyle(color: isDark ? AppColors.accentCyan : AppColors.primaryBlue)),
          ),
        ],
      ),
      body: _isSending
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: isDark ? AppColors.accentCyan : AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Enviando reporte...',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Subiendo evidencias y datos',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Tipo de incidente
                  _buildSectionLabel(theme, 'Tipo de incidente *'),
                  const SizedBox(height: 8),
                  _buildTypeDropdown(theme, isDark),
                  const SizedBox(height: 20),

                  // Urgencia
                  _buildSectionLabel(theme, 'Nivel de urgencia'),
                  const SizedBox(height: 8),
                  _buildUrgencyChips(),
                  const SizedBox(height: 20),

                  // Descripción
                  _buildSectionLabel(theme, 'Descripción *'),
                  const SizedBox(height: 8),
                  _buildDescriptionField(theme, isDark),
                  const SizedBox(height: 20),

                  // Evidencias
                  _buildSectionLabel(theme, 'Evidencias'),
                  const SizedBox(height: 8),
                  _buildEvidenceSection(theme, isDark),
                  const SizedBox(height: 20),

                  // Ubicación
                  _buildSectionLabel(theme, 'Ubicación'),
                  const SizedBox(height: 8),
                  _buildLocationSection(theme, isDark),
                  const SizedBox(height: 20),

                  // Alcance
                  _buildSectionLabel(theme, 'Alcance de notificación'),
                  const SizedBox(height: 8),
                  _buildScopeSection(theme, isDark),
                  const SizedBox(height: 32),

                  // Botones
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _submitReport,
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Enviar reporte', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _saveDraft,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Guardar borrador'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionLabel(ThemeData theme, String label) {
    return Text(label,
        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700));
  }

  Widget _buildTypeDropdown(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedType,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintText: 'Selecciona el tipo',
        ),
        items: _incidentTypes
            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
            .toList(),
        onChanged: (v) => setState(() => _selectedType = v),
        validator: (v) => v == null ? 'Requerido' : null,
      ),
    );
  }

  Widget _buildUrgencyChips() {
    return Row(
      children: List.generate(3, (i) {
        final isSelected = _urgencyIndex == i;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _urgencyIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _urgencyColors[i].withValues(alpha: 0.15)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? _urgencyColors[i]
                        : Theme.of(context).dividerColor.withValues(alpha: 0.15),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_urgencyIcons[i], size: 16, color: _urgencyColors[i]),
                    const SizedBox(width: 4),
                    Text(
                      _urgencyLabels[i],
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                        color: isSelected ? _urgencyColors[i] : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDescriptionField(ThemeData theme, bool isDark) {
    return TextFormField(
      controller: _descController,
      maxLines: 5,
      maxLength: 500,
      decoration: InputDecoration(
        hintText: 'Describe lo que ocurrió con el mayor detalle posible...',
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade300),
        ),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Descripción requerida' : null,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildEvidenceSection(ThemeData theme, bool isDark) {
    return Column(
      children: [
        if (_evidences.isNotEmpty) ...[
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _evidences.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Container(
                  width: 90,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _evidences[index] == 'camera'
                                  ? Icons.camera_alt
                                  : _evidences[index] == 'video'
                                      ? Icons.videocam
                                      : Icons.image,
                              color: Colors.grey,
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(_evidences[index],
                                style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _evidences.removeAt(index)),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addEvidence,
            icon: const Icon(Icons.add_a_photo_rounded, size: 18),
            label: const Text('Agregar evidencia'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on_rounded, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ubicación actual detectada',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text('19.4326° N, 99.1332° W',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Actualizar', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Compartir ubicación en vivo', style: TextStyle(fontSize: 14)),
            subtitle: Text(
              _shareLocation
                  ? 'Se enviará cada 30 segundos mientras el reporte esté activo'
                  : 'No se compartirá ubicación en vivo',
              style: const TextStyle(fontSize: 11),
            ),
            value: _shareLocation,
            onChanged: (v) => setState(() => _shareLocation = v),
            activeColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildScopeSection(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade300),
      ),
      child: Column(
        children: [
          RadioListTile<bool>(
            title: const Text('Notificar solo a mi zona', style: TextStyle(fontSize: 14)),
            subtitle: const Text('Recomendado', style: TextStyle(fontSize: 11)),
            value: true,
            groupValue: _notifyZoneOnly,
            onChanged: (v) => setState(() => _notifyZoneOnly = v!),
            activeColor: AppColors.primaryBlue,
          ),
          Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.withValues(alpha: 0.15)),
          RadioListTile<bool>(
            title: const Text('Notificar a todos', style: TextStyle(fontSize: 14)),
            value: false,
            groupValue: _notifyZoneOnly,
            onChanged: (v) => setState(() => _notifyZoneOnly = v!),
            activeColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }
}
