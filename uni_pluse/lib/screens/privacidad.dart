import 'package:flutter/material.dart';

class PrivacidadScreen extends StatelessWidget {
  const PrivacidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidad'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título principal
            const Text(
              'Tu privacidad es importante',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 20),

            // Sección 1: Introducción
            _buildPrivacySection(
              title: "1. Introducción",
              content:
                  "Esta política describe cómo recopilamos, usamos y protegemos tu información cuando utilizas nuestra aplicación. Al usar el servicio, aceptas estas prácticas.",
            ),

            // Sección 2: Datos recopilados
            _buildPrivacySection(
              title: "2. Datos que recopilamos",
              content:
                  "Podemos recopilar información no personal (como tipo de dispositivo) y datos personales que nos proporciones voluntariamente (como email). No accedemos a contactos, fotos u otros datos sensibles sin tu permiso explícito.",
            ),

            // Sección 3: Uso de datos
            _buildPrivacySection(
              title: "3. ¿Cómo usamos tus datos?",
              content:
                  "Los datos se utilizan para:\n\n• Mejorar la experiencia de usuario\n• Proporcionar soporte técnico\n• Enviar actualizaciones (si optas por ello)\n• Cumplir con requisitos legales",
            ),

            // Sección 4: Seguridad
            _buildPrivacySection(
              title: "4. Seguridad",
              content:
                  "Implementamos medidas de seguridad técnicas y organizativas para proteger tu información. Sin embargo, ningún sistema es 100% seguro, por lo que no podemos garantizar seguridad absoluta.",
            ),

            // Sección 5: Terceros
            _buildPrivacySection(
              title: "5. Servicios de terceros",
              content:
                  "Utilizamos servicios como Google Analytics para analizar el uso de la app. Estos terceros tienen sus propias políticas de privacidad que recomendamos revisar.",
            ),

            // Sección 6: Cambios
            _buildPrivacySection(
              title: "6. Cambios en esta política",
              content:
                  "Podemos actualizar esta política ocasionalmente. Te notificaremos sobre cambios significativos mediante una notificación en la app o por email.",
            ),

            // Contacto
            const SizedBox(height: 30),
            const Center(
              child: Column(
                children: [
                  Text(
                    "¿Preguntas? Contáctanos:",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "privacidad@app.com",
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para secciones
  Widget _buildPrivacySection({
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 15, height: 1.4),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
