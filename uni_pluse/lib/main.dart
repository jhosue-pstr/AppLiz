import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'screens/inicio.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('es'), Locale('en')],
      path: 'assets/langs',
      fallbackLocale: const Locale('es'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Liz',
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: InicioScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => HomeScreen(
              email: args['email'],
              passwordHash: args['password_hash'],
              name: args['name'],
              lastnamePaternal: args['lastname_paternal'],
              lastnameMaternal: args['lastname_maternal'],
              avatarUrl: args['avatar_url'] ?? 'assets/images/avatar1.png',
              bio: args['bio'],
              currentlyWorking: args['currently_working'],
              workingHoursPerDay: args['working_hours_per_day'],
              points: args['points'],
            ),
          );
        }
        return null;
      },
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}
