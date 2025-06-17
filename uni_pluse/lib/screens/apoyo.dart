import 'package:flutter/material.dart';

class ApoyoScreen extends StatelessWidget {
  final int userId;

  const ApoyoScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apoyo')),
      body: Container(), // Add a body widget here
    );
  }
}
