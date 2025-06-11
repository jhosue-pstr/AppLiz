import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'accesibilidad_provider.dart';

class AccesibilidadScreen extends StatelessWidget {
  const AccesibilidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final acces = Provider.of<AccesibilidadProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Accesibilidad')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text("Modo oscuro"),
            value: acces.isDarkMode,
            onChanged: acces.toggleDarkMode,
          ),
          const SizedBox(height: 16),
          Text("Tamaño del texto: ${acces.textScale.toStringAsFixed(1)}"),
          Slider(
            min: 0.8,
            max: 1.5,
            divisions: 7,
            label: acces.textScale.toStringAsFixed(1),
            value: acces.textScale,
            onChanged: acces.updateTextScale,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text("Reducir animaciones"),
            value: acces.reduceAnimations,
            onChanged: acces.toggleReduceAnimations,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text("Contraste alto"),
            value: acces.highContrast,
            onChanged: acces.toggleHighContrast,
          ),
        ],
      ),
    );
  }
}
