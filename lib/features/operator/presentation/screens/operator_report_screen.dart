import 'package:flutter/material.dart';

class OperatorReportScreen extends StatelessWidget {
  const OperatorReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar Reporte'),
      ),
      body: const Center(
        child: Text('Formulario para reportar incidente vecinal (Próximamente)'),
      ),
    );
  }
}
