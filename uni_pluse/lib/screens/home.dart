import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'perfil.dart';
import 'diario.dart';

class HomeScreen extends StatelessWidget {
  final String email;
  final String passwordHash;
  final String name;
  final String lastnamePaternal;
  final String lastnameMaternal;
  final String avatarUrl;
  final String bio;
  final bool currentlyWorking;
  final int workingHoursPerDay;
  final int points;

  HomeScreen({
    required this.email,
    required this.passwordHash,
    required this.name,
    required this.lastnamePaternal,
    required this.lastnameMaternal,
    required this.avatarUrl,
    required this.bio,
    required this.currentlyWorking,
    required this.workingHoursPerDay,
    required this.points,
    super.key,
  });

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar sesión'),
          content: Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
  }

  void _showPointsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'TUS RECOMPENSAS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber[100],
                    border: Border.all(color: Colors.orange, width: 3),
                  ),
                  child: Text(
                    '$points',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Sigue acumulando puntos',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 30),
                _buildInfoCard(),
              ],
            ),
          ),
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
              'Puntos: $points',
              style: TextStyle(fontSize: 14, color: Colors.black),
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
      body: SingleChildScrollView(
        child: Padding(
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
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Tus herramientas:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PerfilScreen(
                        name: name,
                        points: points,
                        avatarUrl: avatarUrl,
                        bio: bio,
                        currentlyWorking: currentlyWorking,
                        workingHoursPerDay: workingHoursPerDay,
                        email: email,
                        passwordHash: passwordHash,
                        lastnamePaternal: lastnamePaternal,
                        lastnameMaternal: lastnameMaternal,
                      ),
                    ),
                  );
                },
                child: _buildColorBlock('Perfil', Colors.red.shade700),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiarioScreen(userId: 1),
                    ),
                  );
                },
                child: _buildColorBlock(
                  'Diario emocional',
                  Colors.blue.shade700,
                ),
              ),
              SizedBox(height: 10),
              _buildColorBlock('Fuerza Charlie', Colors.green.shade700),
              SizedBox(height: 10),
              _buildColorBlock('Fuerza Delta', Colors.orange.shade700),
              SizedBox(height: 10),
              _buildColorBlock('Fuerza Épsilon', Colors.purple.shade700),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPointsModal(context),
        child: Icon(Icons.emoji_events),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildColorBlock(String title, Color color) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  'Cómo ganar puntos:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildPointInfo('+3 puntos', 'Por iniciar sesión cada día'),
            _buildPointInfo('+5 puntos', 'Por registrar tu estado emocional'),
            _buildPointInfo('+10 puntos', 'Por completar una semana'),
          ],
        ),
      ),
    );
  }

  Widget _buildPointInfo(String points, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              points,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(description, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }
}
