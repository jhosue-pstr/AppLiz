import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SeguridadScreen extends StatefulWidget {
  const SeguridadScreen({super.key});

  @override
  _SeguridadScreenState createState() => _SeguridadScreenState();
}

class _SeguridadScreenState extends State<SeguridadScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController currentPassCtrl = TextEditingController();
  final TextEditingController newPassCtrl = TextEditingController();
  final TextEditingController confirmPassCtrl = TextEditingController();

  bool isLoading = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await http.put(
        Uri.parse(
          'http://appliz-backend-production.up.railway.app/api/users/me/password',
        ),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'current_password': currentPassCtrl.text,
          'new_password': newPassCtrl.text,
        }),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña actualizada correctamente')),
        );
        currentPassCtrl.clear();
        newPassCtrl.clear();
        confirmPassCtrl.clear();
      } else {
        final body = json.decode(response.body);
        throw Exception(body['error'] ?? 'Error desconocido');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.delete(
          Uri.parse(
            'http://appliz-backend-production.up.railway.app/api/users/me',
          ),
          headers: {'Authorization': 'Bearer $_token'},
        );

        if (response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('token');

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cuenta eliminada exitosamente')),
            );
            Navigator.of(context).pushReplacementNamed('/login');
          }
        } else {
          throw Exception('Error: ${response.body}');
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al eliminar cuenta: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguridad')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPasswordField(
                controller: currentPassCtrl,
                label: 'Contraseña actual',
                isRequired: true,
              ),
              _buildPasswordField(
                controller: newPassCtrl,
                label: 'Nueva contraseña',
                isRequired: true,
              ),
              _buildPasswordField(
                controller: confirmPassCtrl,
                label: 'Confirmar nueva contraseña',
                isRequired: true,
                confirmAgainst: newPassCtrl,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _updatePassword,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Actualizar contraseña'),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _deleteAccount,
                icon: const Icon(Icons.delete),
                label: const Text('Eliminar Cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextEditingController? confirmAgainst,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Este campo es requerido';
          }
          if (confirmAgainst != null && value != confirmAgainst.text) {
            return 'Las contraseñas no coinciden';
          }
          return null;
        },
      ),
    );
  }
}
