import 'package:flutter/material.dart';

class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Ayuda'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner superior
            _buildHelpBanner(),
            const SizedBox(height: 30),

            // Sección de preguntas frecuentes
            const Text(
              'Preguntas Frecuentes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 15),
            _buildFAQItem(
              question: "¿Cómo restablezco mi contraseña?",
              answer: "Ve a Configuración > Seguridad > Cambiar contraseña.",
            ),
            _buildFAQItem(
              question: "¿Dónde veo mis pagos?",
              answer: "En la sección 'Historial' de tu perfil.",
            ),
            const SizedBox(height: 30),

            // Sección de contacto
            const Text(
              'Contacto Directo',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 15),
            _buildContactOption(
              icon: Icons.email,
              title: "Correo electrónico",
              subtitle: "soporte@app.com",
            ),
            _buildContactOption(
              icon: Icons.phone,
              title: "Teléfono",
              subtitle: "+1 234 567 890",
            ),
            const SizedBox(height: 40),

            // Footer
            const Center(
              child: Text(
                "Versión 1.0.0",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Componentes reutilizables
  Widget _buildHelpBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.help_outline, size: 40, color: Colors.indigo),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "¿Necesitas ayuda?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "Revisa nuestras preguntas frecuentes o contáctanos directamente.",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(15).copyWith(top: 0),
            child: Text(answer, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      onTap: () {}, // Sin funcionalidad (estático)
    );
  }
}
