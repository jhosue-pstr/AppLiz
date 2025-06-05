import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login.dart';
import 'services/api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;

  MyApp({this.token});

  @override
  Widget build(BuildContext context) {
    if (token != null) ApiService.setToken(token!);

    return MaterialApp(
      title: 'App Liz',
      debugShowCheckedModeBanner: false,
      home: token == null
          ? LoginScreen()
          : Placeholder(), // Cambiar Placeholder por Home después
    );
  }
}
