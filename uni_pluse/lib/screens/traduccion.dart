import 'package:flutter/material.dart';

class TraduccionScreen extends StatelessWidget {
  const TraduccionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Traducción')),
      body: const Center(child: Text('Pantalla de Traducción')),
    );
  }
}
