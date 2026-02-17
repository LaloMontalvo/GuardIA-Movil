import 'package:flutter/material.dart';

/// Pantalla de creación de incidente manual
class CreateIncidentScreen extends StatefulWidget {
  const CreateIncidentScreen({super.key});

  @override
  State<CreateIncidentScreen> createState() => _CreateIncidentScreenState();
}

class _CreateIncidentScreenState extends State<CreateIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedType = 'intrusión';
  final List<String> _attachments = [];

  final _types = ['intrusión', 'persona sospechosa', 'incendio', 'vandalismo', 'robo', 'otro'];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _addAttachment() {
    setState(() {
      _attachments.add('captura_${_attachments.length + 1}.jpg');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Archivo adjuntado (simulado)')),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Incidente reportado exitosamente'), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportar Incidente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.report_problem_rounded, size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('Crear reporte de incidente',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Tipo de incidente', prefixIcon: Icon(Icons.category_outlined)),
                items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t[0].toUpperCase() + t.substring(1)))).toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe lo que ocurrió...',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(padding: EdgeInsets.only(bottom: 60), child: Icon(Icons.description_outlined)),
                ),
                validator: (v) => v?.isEmpty == true ? 'Agrega una descripción' : null,
              ),
              const SizedBox(height: 16),
              // Location auto
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.green),
                  title: const Text('Ubicación detectada'),
                  subtitle: const Text('Lat: 25.6866, Lng: -100.3161'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
              ),
              const SizedBox(height: 16),
              // Attachments
              Text('Adjuntos', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              if (_attachments.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _attachments.map((a) => Chip(
                    avatar: const Icon(Icons.image, size: 16),
                    label: Text(a),
                    onDeleted: () => setState(() => _attachments.remove(a)),
                  )).toList(),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _addAttachment,
                icon: const Icon(Icons.attach_file),
                label: const Text('Adjuntar archivo'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Enviar Reporte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
