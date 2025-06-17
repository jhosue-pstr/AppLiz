import 'package:flutter/material.dart';
import 'notas.dart';

class GestionToolsScreen extends StatelessWidget {
  final int userId;

  const GestionToolsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Herramientas de Gestión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotesScreen(userId: userId),
                ),
              ),
              child: _buildColorBlock('Notas', Colors.purple, Icons.note),
            ),
            GestureDetector(
              onTap: () => _showSnackbar(context, 'Tareas presionado'),
              child: _buildColorBlock('Tareas', Colors.blue, Icons.task),
            ),
            GestureDetector(
              onTap: () => _showSnackbar(context, 'Incidencias presionado'),
              child: _buildColorBlock('Incidencias', Colors.red, Icons.warning),
            ),
            GestureDetector(
              onTap: () => _showSnackbar(context, 'Eventos presionado'),
              child: _buildColorBlock('Eventos', Colors.green, Icons.event),
            ),
            GestureDetector(
              onTap: () => _showSnackbar(context, 'Asistencias presionado'),
              child: _buildColorBlock(
                'Asistencias',
                Colors.amber,
                Icons.people,
              ),
            ),
            GestureDetector(
              onTap: () => _showSnackbar(context, 'Cerrar periodo presionado'),
              child: _buildColorBlock(
                'Cerrar periodo',
                Colors.indigo,
                Icons.calendar_today,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorBlock(String title, Color color, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}
