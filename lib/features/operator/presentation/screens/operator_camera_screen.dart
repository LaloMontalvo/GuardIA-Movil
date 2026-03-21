import 'package:flutter/material.dart';

class OperatorCameraScreen extends StatelessWidget {
  const OperatorCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Cámara'),
      ),
      body: const Center(
        child: Text('Ver mi cámara privada vecinal (Próximamente)'),
      ),
    );
  }
}
