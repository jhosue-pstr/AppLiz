import 'package:flutter/material.dart';

class LicenciasScreen extends StatelessWidget {
  const LicenciasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Licencias de código abierto')),
      body: const Center(
        child: Text('Pantalla de Licencias de código abierto'),
      ),
    );
  }
}
