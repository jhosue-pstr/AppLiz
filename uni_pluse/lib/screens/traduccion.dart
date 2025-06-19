import 'package:flutter/material.dart';

class TraduccionScreen extends StatelessWidget {
  const TraduccionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Idiomas de la App'), centerTitle: true),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            Text(
              'Soporte de Idiomas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 20),

            // Información principal
            Text(
              'Actualmente la app está disponible en:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 15),

            // Lista de idiomas
            _LanguageItem(flag: '🇪🇸', language: 'Español'),
            _LanguageItem(flag: '🇺🇸', language: 'Inglés (próximamente)'),
            _LanguageItem(flag: '🇫🇷', language: 'Francés (próximamente)'),

            // Nota adicional
            SizedBox(height: 30),
            Text(
              '¿Quieres ayudarnos a traducir la app a tu idioma?',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 5),
            Text(
              'Contáctanos: soporte@app.com',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Componente para ítem de idioma
class _LanguageItem extends StatelessWidget {
  final String flag;
  final String language;

  const _LanguageItem({required this.flag, required this.language});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 15),
          Text(language, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
