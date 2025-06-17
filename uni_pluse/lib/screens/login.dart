import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final String apiUrl = 'http://127.0.0.1:5000/api/auth/login';

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', data['user_id']);
        await prefs.setString('token', data['token']);
        await prefs.setString('email', data['email']);
        await prefs.setString('password_hash', data['password_hash'] ?? '');
        await prefs.setString('name', data['name']);
        await prefs.setString(
          'lastname_paternal',
          data['lastname_paternal'] ?? '',
        );
        await prefs.setString(
          'lastname_maternal',
          data['lastname_maternal'] ?? '',
        );
        await prefs.setString('avatar_url', data['avatar_url'] ?? '');
        await prefs.setString('bio', data['bio'] ?? '');
        await prefs.setBool(
          'currently_working',
          data['currently_working'] == 1,
        );
        await prefs.setInt(
          'working_hours_per_day',
          data['working_hours_per_day'] ?? 0,
        );
        await await prefs.setInt('points', data['points']);

        if (data['daily_points_added'] > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '¡Has ganado ${data['daily_points_added']} puntos por iniciar sesión hoy!',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }

        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: {
            'token': data['token'],
            'user_id': int.parse(data['user_id'].toString()),
            'email': data['email'],
            'password_hash': data['password_hash'] ?? '',
            'name': data['name'],
            'lastname_paternal': data['lastname_paternal'] ?? '',
            'lastname_maternal': data['lastname_maternal'] ?? '',
            'avatar_url': data['avatar_url'] ?? '',
            'bio': data['bio'] ?? '',
            'currently_working': data['currently_working'] == 1,
            'working_hours_per_day': data['working_hours_per_day'] ?? 0,
            'points': data['points'],
          },
        );
      } else {
        final error = jsonDecode(response.body)['error'];
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 30),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: Text('Ingresar'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
