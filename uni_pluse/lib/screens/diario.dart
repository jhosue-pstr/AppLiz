import 'package:flutter/material.dart';

class DiarioScreen extends StatelessWidget {
  const DiarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Diario Emocional')),
      body: Center(
        child: Text(
          'Aquí irá tu diario emocional',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
