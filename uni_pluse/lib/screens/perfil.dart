import 'package:flutter/material.dart';
import 'informacion.dart';
import 'seguridad.dart';
import 'accesibilidad.dart';
import 'pagos.dart';
import 'ayuda.dart';
import 'traduccion.dart';
import 'privacidad.dart';
import 'licencias.dart';

class PerfilScreen extends StatelessWidget {
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

  const PerfilScreen({
    super.key,
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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Tu Perfil', style: TextStyle(color: textColor)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: avatarUrl.startsWith('http')
                      ? NetworkImage(avatarUrl)
                      : AssetImage(avatarUrl) as ImageProvider,
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.home_outlined, size: 40, color: textColor),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Anfitrión Jhon",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Tu bienestar emocional, tu mejor herramienta.",
                          style: TextStyle(color: textColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Configuración',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          _buildOption(context, Icons.person_outline, 'Información Personal'),
          _buildOption(
            context,
            Icons.lock_outline,
            'Inicio de Sesión y Seguridad',
          ),
          _buildOption(context, Icons.payments_outlined, 'Pagos y Cobros'),
          _buildOption(
            context,
            Icons.accessibility_new_outlined,
            'Accesibilidad',
          ),
          _buildOption(context, Icons.help_outline, 'Obten ayuda'),
          _buildOption(context, Icons.translate, 'Traducción'),
          _buildOption(
            context,
            Icons.privacy_tip_outlined,
            'Política de privacidad',
          ),
          _buildOption(context, Icons.code, 'Licencias de código abierto'),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, IconData icon, String title) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
      onTap: () {
        if (title == 'Información Personal') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InformacionScreen()),
          );
        } else if (title == 'Inicio de Sesión y Seguridad') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SeguridadScreen()),
          );
        } else if (title == 'Accesibilidad') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AccesibilidadScreen(),
            ),
          );
        } else if (title == 'Pagos y Cobros') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PagosScreen()),
          );
        } else if (title == 'Obten ayuda') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AyudaScreen()),
          );
        } else if (title == 'Traducción') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TraduccionScreen()),
          );
        } else if (title == 'Política de privacidad') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PrivacidadScreen()),
          );
        } else if (title == 'Licencias de código abierto') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LicenciasScreen()),
          );
        }
      },
    );
  }
}
