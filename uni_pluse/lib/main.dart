import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'screens/inicio.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/home.dart';
import 'screens/accesibilidad.dart';
import 'screens/accesibilidad_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final textScale = prefs.getDouble('textScale') ?? 1.0;
  final highContrast = prefs.getBool('highContrast') ?? false;
  final language = prefs.getString('language') ?? 'es';

  runApp(
    ChangeNotifierProvider(
      create: (_) => AccesibilidadProvider()
        ..isDarkMode = isDarkMode
        ..textScale = textScale
        ..highContrast = highContrast
        ..language = language,
      child: EasyLocalization(
        supportedLocales: [Locale('es'), Locale('en')],
        path: 'assets/langs',
        fallbackLocale: Locale('es'),
        startLocale: Locale(language),
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final acces = Provider.of<AccesibilidadProvider>(context);
    final baseLight = ThemeData.light();
    final baseDark = ThemeData.dark();

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: acces.textScale),
      child: MaterialApp(
        title: 'App Liz',
        debugShowCheckedModeBanner: false,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        theme: acces.highContrast
            ? ThemeData.from(colorScheme: ColorScheme.highContrastLight())
            : baseLight,
        darkTheme: acces.highContrast
            ? ThemeData.from(colorScheme: ColorScheme.highContrastDark())
            : baseDark,
        themeMode: acces.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: InicioScreen(),
        onGenerateRoute: (settings) {
          if (settings.name == '/home') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => HomeScreen(
                email: args['email'],
                userId: args['user_id'] as int,
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
          '/accesibilidad': (context) => AccesibilidadScreen(),
        },
      ),
    );
  }
}
