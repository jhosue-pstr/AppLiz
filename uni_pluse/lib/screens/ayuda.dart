import 'package:flutter/material.dart';

class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Obten Ayuda')),
      body: const Center(child: Text('Pantalla de Ayuda')),
    );
  }
}
