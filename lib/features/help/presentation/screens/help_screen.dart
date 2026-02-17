import 'package:flutter/material.dart';

/// Pantalla de ayuda y soporte
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayuda y Soporte')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick actions
          Row(
            children: [
              Expanded(
                child: _HelpAction(
                  icon: Icons.chat_outlined,
                  label: 'Chat en vivo',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat en vivo no disponible en modo demo')));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HelpAction(
                  icon: Icons.email_outlined,
                  label: 'Enviar correo',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abrir email: soporte@guardia.com')));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HelpAction(
                  icon: Icons.phone_outlined,
                  label: 'Llamar',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Llamar: 55-1234-5678')));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // FAQ
          Text('Preguntas frecuentes', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _FaqItem(question: '¿Cómo agrego una nueva cámara?', answer: 'Ve a la sección de cámaras, presiona el botón (+) y sigue los pasos del asistente de configuración.'),
          _FaqItem(question: '¿Cómo funciona el botón de pánico?', answer: 'El botón de pánico envía una alerta con tu ubicación a todos los administradores y contactos de emergencia.'),
          _FaqItem(question: '¿Puedo ver grabaciones antiguas?', answer: 'Sí, en la sección de Grabaciones puedes filtrar por fecha, cámara y tipo de evento.'),
          _FaqItem(question: '¿Cómo exporto evidencia?', answer: 'En la sección Evidencias, puedes crear un caso, agregar clips y exportar un paquete completo.'),
          _FaqItem(question: '¿Qué hago si una cámara está offline?', answer: 'Verifica la conexión de red y alimentación de la cámara. Si persiste, contacta a soporte técnico.'),

          const SizedBox(height: 24),

          // Tickets
          Text('Mis tickets de soporte', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.withOpacity(0.15),
                child: const Icon(Icons.confirmation_number, color: Colors.orange),
              ),
              title: const Text('Cámara sin conexión'),
              subtitle: const Text('En progreso · Hace 2 días'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateTicketScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Nuevo ticket de soporte'),
          ),

          const SizedBox(height: 24),

          // Legal links
          Text('Legal', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Términos y condiciones'),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Política de privacidad'),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Acerca de GuardIA'),
                  subtitle: const Text('Versión 1.0.0'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'GuardIA',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.shield, size: 48, color: Colors.blue),
                      children: const [Text('Plataforma de videovigilancia comunitaria con IA.')],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _HelpAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question, answer;
  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontSize: 14)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [Text(answer, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)))],
      ),
    );
  }
}

/// Crear ticket de soporte
class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = 'Cámaras';

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Ticket')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Categoría', prefixIcon: Icon(Icons.category)),
                items: ['Cámaras', 'Alertas', 'Cuenta', 'Facturación', 'Otro']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Asunto', prefixIcon: Icon(Icons.title)),
                validator: (v) => v?.isEmpty == true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe tu problema en detalle...',
                  alignLabelWithHint: true,
                ),
                validator: (v) => v?.isEmpty == true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Archivo adjuntado (simulado)')));
                },
                icon: const Icon(Icons.attach_file),
                label: const Text('Adjuntar archivo'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ticket creado exitosamente'), backgroundColor: Colors.green),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Enviar Ticket'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
