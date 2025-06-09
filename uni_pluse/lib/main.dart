import 'package:flutter/material.dart';
import 'screens/inicio.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Liz',
      debugShowCheckedModeBanner: false,
      home: InicioScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => HomeScreen(
              name: args['name'], // Pasa el nombre del usuario
              points: args['points'], // Pasa los puntos del usuario
            ),
          );
        }
        return null;
      },
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}
