import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class InformacionScreen extends StatefulWidget {
  const InformacionScreen({super.key});

  @override
  _InformacionScreenState createState() => _InformacionScreenState();
}

class _InformacionScreenState extends State<InformacionScreen> {
  bool isLoading = true, isEditing = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController lastNameMatCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController bioCtrl = TextEditingController();
  final TextEditingController avatarCtrl = TextEditingController();
  final TextEditingController hoursCtrl = TextEditingController();

  bool currentlyWorking = false;
  String stressFreq = 'medio';
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchProfile();
  }

  Future<void> _loadTokenAndFetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token')?.trim(); // Limpia espacios

      if (_token == null || _token!.isEmpty) {
        throw Exception('Token no encontrado');
      }

      // Debug: Verifica el token
      debugPrint('Token recuperado: $_token');
      debugPrint('Longitud del token: ${_token?.length}');

      await _fetchProfile();
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar token: $e')));
      Navigator.pushReplacementNamed(context, '/login'); // Redirige a login
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://appliz-backend-production.up.railway.app/api/users/me',
        ),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          nameCtrl.text = data['name'] ?? '';
          lastNameCtrl.text = data['lastname_paternal'] ?? '';
          lastNameMatCtrl.text = data['lastname_maternal'] ?? '';
          emailCtrl.text = data['email'] ?? '';
          bioCtrl.text = data['bio'] ?? '';
          avatarCtrl.text = data['avatar_url'] ?? '';
          currentlyWorking = data['currently_working'] == 1;
          hoursCtrl.text = (data['working_hours_per_day'] ?? 0).toString();
          stressFreq = data['stress_frequency'] ?? 'medio';
          isLoading = false;
        });
      } else {
        throw Exception('Error al cargar perfil: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await http.patch(
        Uri.parse(
          'https://appliz-backend-production.up.railway.app/api/users/me',
        ),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': nameCtrl.text,
          'lastname_paternal': lastNameCtrl.text,
          'lastname_maternal': lastNameMatCtrl.text,
          'email': emailCtrl.text,
          'bio': bioCtrl.text,
          'avatar_url': avatarCtrl.text,
          'currently_working': currentlyWorking ? 1 : 0,
          'working_hours_per_day': int.tryParse(hoursCtrl.text) ?? 0,
          'stress_frequency': stressFreq,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
        setState(() => isEditing = false);
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Información Personal'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _updateProfile();
              } else {
                setState(() => isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildEditableField(
                controller: nameCtrl,
                label: 'Nombre',
                isRequired: true,
              ),
              _buildEditableField(
                controller: lastNameCtrl,
                label: 'Apellido Paterno',
                isRequired: true,
              ),
              _buildEditableField(
                controller: lastNameMatCtrl,
                label: 'Apellido Materno',
              ),
              _buildEditableField(
                controller: bioCtrl,
                label: 'Biografía',
                maxLines: 3,
              ),
              _buildEditableField(
                controller: avatarCtrl,
                label: 'URL del Avatar',
              ),
              SwitchListTile(
                title: const Text('Actualmente trabajando'),
                value: currentlyWorking,
                onChanged: isEditing
                    ? (val) => setState(() => currentlyWorking = val)
                    : null,
              ),
              _buildEditableField(
                controller: hoursCtrl,
                label: 'Horas de trabajo por día',
                keyboardType: TextInputType.number,
              ),
              _buildStressDropdown(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    bool isEmail = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        enabled: isEditing,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Este campo es requerido';
          }
          if (isEmail && value != null && !value.contains('@')) {
            return 'Ingresa un email válido';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildStressDropdown() {
    return DropdownButtonFormField<String>(
      value: stressFreq,
      decoration: const InputDecoration(labelText: 'Frecuencia de Estrés'),
      items: const [
        DropdownMenuItem(value: 'bajo', child: Text('Bajo')),
        DropdownMenuItem(value: 'medio', child: Text('Medio')),
        DropdownMenuItem(value: 'alto', child: Text('Alto')),
      ],
      onChanged: isEditing
          ? (value) => setState(() => stressFreq = value!)
          : null,
    );
  }
}
