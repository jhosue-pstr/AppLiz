import 'package:flutter/material.dart';

class ComunidadScreen extends StatelessWidget {
  final int userId;

  const ComunidadScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comunidad')),
      body: Container(), // Add a body widget here
    );
  }
}
