import 'package:flutter/material.dart';

class OperatorHistoryScreen extends StatelessWidget {
  const OperatorHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Avisos'),
      ),
      body: const Center(
        child: Text('Lista de notificaciones y reportes del vecindario (Próximamente)'),
      ),
    );
  }
}
