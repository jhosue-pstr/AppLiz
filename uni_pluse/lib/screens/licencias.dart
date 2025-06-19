import 'package:flutter/material.dart';

class LicenciasScreen extends StatelessWidget {
  const LicenciasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Licencias Open Source'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estilo épico
            Center(
              child: Column(
                children: [
                  const Text(
                    '⚖️ Créditos Legales',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'UniPluse v1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 25),

            // Mensaje personalizado
            Card(
              color: Colors.amber[50],
              child: const Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  'Esta app no existiría sin el código abierto y las empanadas que alimentan al dev.',
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Librerías usadas (reales de tu pubspec.yaml)
            _buildLicenseCard(
              package: "http",
              license: "BSD-3",
              author: "Dart Team",
              description: "Para peticiones HTTP a APIs.",
            ),
            _buildLicenseCard(
              package: "provider",
              license: "MIT",
              author: "Remi Rousselet",
              description: "Gestión de estado sencilla.",
            ),
            _buildLicenseCard(
              package: "shared_preferences",
              license: "Apache 2.0",
              author: "Flutter Team",
              description: "Almacenamiento local persistente.",
            ),
            _buildLicenseCard(
              package: "flutter_dotenv",
              license: "MIT",
              author: "Tony Edwards",
              description: "Variables de entorno en .env.",
            ),
            _buildLicenseCard(
              package: "easy_localization",
              license: "MIT",
              author: "Tien Do Nam",
              description: "Internacionalización de la app.",
            ),
            _buildLicenseCard(
              package: "fl_chart",
              license: "MIT",
              author: "Iman Khoshabi",
              description: "Gráficos personalizados.",
            ),

            // Agradecimientos épicos
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),
            const Center(
              child: Column(
                children: [
                  Text(
                    "Agradecimientos Especiales:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("• A Liz, por la paciencia infinita"),
                  Text("• A la empanada de pago (que espero recibir)"),
                  Text("• Al café que mantuvo al dev despierto"),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Footer con datos del Ingeñero
            Center(
              child: Column(
                children: [
                  const Text(
                    "Desarrollado por:",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Pastor (el Ingeñero)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {}, // Podrías añadir url_launcher aquí luego
                    child: const Text(
                      "github.com/jhosue-pstr",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "© ${DateTime.now().year} - Hecho con Flutter",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseCard({
    required String package,
    required String license,
    required String author,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.code, size: 18, color: Colors.indigo),
                ),
                const SizedBox(width: 10),
                Text(
                  package,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text(license),
                  labelStyle: const TextStyle(fontSize: 11),
                  backgroundColor: Colors.green[50],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 35.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Por: $author",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 5),
                  Text(description, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
