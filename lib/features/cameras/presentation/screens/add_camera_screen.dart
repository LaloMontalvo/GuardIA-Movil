import 'package:flutter/material.dart';
import '../../domain/enums/camera_status.dart';

/// Formulario para agregar cámara (admin)
class AddCameraScreen extends StatefulWidget {
  const AddCameraScreen({super.key});

  @override
  State<AddCameraScreen> createState() => _AddCameraScreenState();
}

class _AddCameraScreenState extends State<AddCameraScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _urlController = TextEditingController();
  String _selectedZone = 'Zona A';
  String _selectedType = 'IP';
  bool _testing = false;
  bool _testPassed = false;

  final _zones = ['Zona A', 'Zona B', 'Zona C', 'Zona D'];
  final _types = ['IP', 'RTSP', 'HLS', 'USB'];

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() => _testing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _testing = false;
      _testPassed = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conexión exitosa (simulado)'), backgroundColor: Colors.green),
      );
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cámara agregada exitosamente (simulado)'), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Cámara')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la cámara',
                  prefixIcon: Icon(Icons.videocam_outlined),
                ),
                validator: (v) => v?.isEmpty == true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) => v?.isEmpty == true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedZone,
                decoration: const InputDecoration(
                  labelText: 'Zona',
                  prefixIcon: Icon(Icons.map_outlined),
                ),
                items: _zones.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
                onChanged: (v) => setState(() => _selectedZone = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de cámara',
                  prefixIcon: Icon(Icons.camera_outlined),
                ),
                items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL del stream',
                  prefixIcon: Icon(Icons.link),
                  hintText: 'rtsp://...',
                ),
                validator: (v) => v?.isEmpty == true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _testing ? null : _testConnection,
                icon: _testing
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(_testPassed ? Icons.check_circle : Icons.wifi_find),
                label: Text(_testing ? 'Probando...' : _testPassed ? 'Conexión OK' : 'Probar conexión'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Guardar cámara'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
