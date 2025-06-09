import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  final String name; // Recibe el nombre del usuario
  final int points; // Recibe los puntos del usuario

  HomeScreen({required this.name, required this.points});

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpia todos los datos almacenados

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar sesión'),
          content: Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el cuadro de diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el cuadro de diálogo
                Navigator.pushReplacementNamed(
                  context,
                  '/login',
                ); // Redirige al login
              },
              child: Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inicio'),
            Text(
              'Monedas: $points',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 150,
                height: 150,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                '¡Hola, $name!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            // Bloques coloreados con nombres fuertes
            _buildColorBlock('Fuerza Alpha', Colors.red.shade700),
            SizedBox(height: 10),
            _buildColorBlock('Fuerza Bravo', Colors.blue.shade700),
            SizedBox(height: 10),
            _buildColorBlock('Fuerza Charlie', Colors.green.shade700),
            SizedBox(height: 10),
            _buildColorBlock('Fuerza Delta', Colors.orange.shade700),
            SizedBox(height: 10),
            _buildColorBlock('Fuerza Épsilon', Colors.purple.shade700),
          ],
        ),
      ),
    );
  }

  // Método privado para construir cada bloque de color con texto
  Widget _buildColorBlock(String title, Color color) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
