import 'package:flutter/material.dart';
import '../../../../shared/widgets/confirm_dialog.dart';

/// Formulario para editar cámara (admin)
class EditCameraScreen extends StatefulWidget {
  final String cameraId;
  const EditCameraScreen({super.key, required this.cameraId});

  @override
  State<EditCameraScreen> createState() => _EditCameraScreenState();
}

class _EditCameraScreenState extends State<EditCameraScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Cámara Entrada Principal');
  final _locationController = TextEditingController(text: 'Puerta de ingreso');
  String _selectedZone = 'Zona A';
  bool _recordingEnabled = true;
  bool _detectionEnabled = true;
  bool _notificationsEnabled = true;

  final _zones = ['Zona A', 'Zona B', 'Zona C', 'Zona D'];

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cámara actualizada (simulado)'), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Eliminar Cámara',
      message: '¿Estás seguro de eliminar esta cámara? Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      isDangerous: true,
      icon: Icons.delete_forever,
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cámara eliminada (simulado)')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Cámara'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.videocam_outlined)),
                validator: (v) => v?.isEmpty == true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Ubicación', prefixIcon: Icon(Icons.location_on_outlined)),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedZone,
                decoration: const InputDecoration(labelText: 'Zona', prefixIcon: Icon(Icons.map_outlined)),
                items: _zones.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
                onChanged: (v) => setState(() => _selectedZone = v!),
              ),
              const SizedBox(height: 24),
              Text('Configuración', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              SwitchListTile(
                title: const Text('Grabación continua'),
                subtitle: const Text('Grabar automáticamente cuando esté en línea'),
                value: _recordingEnabled,
                onChanged: (v) => setState(() => _recordingEnabled = v),
              ),
              SwitchListTile(
                title: const Text('Detección de movimiento'),
                subtitle: const Text('Generar alertas por movimiento'),
                value: _detectionEnabled,
                onChanged: (v) => setState(() => _detectionEnabled = v),
              ),
              SwitchListTile(
                title: const Text('Notificaciones'),
                subtitle: const Text('Enviar notificaciones de esta cámara'),
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Guardar cambios'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cámara desactivada (simulado)')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Desactivar cámara'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
