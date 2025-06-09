import 'package:flutter/material.dart';
import 'screens/inicio.dart'; // Importa la pantalla inicial
import 'screens/login.dart'; // Importa la pantalla de login
import 'screens/register.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Liz',
      debugShowCheckedModeBanner: false,
      home: InicioScreen(), // Pantalla inicial
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) =>
            RegisterScreen(), // Ruta para register.dart // Ruta para login.dart
      },
    );
  }
}
