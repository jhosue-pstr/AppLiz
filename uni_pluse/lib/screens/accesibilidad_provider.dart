import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccesibilidadProvider extends ChangeNotifier {
  bool isDarkMode = false;
  double textScale = 1.0;
  bool reduceAnimations = false;
  bool highContrast = false;
  String language = 'es';

  AccesibilidadProvider() {
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool('isDarkMode') ?? false;
    textScale = prefs.getDouble('textScale') ?? 1.0;
    reduceAnimations = prefs.getBool('reduceAnimations') ?? false;
    highContrast = prefs.getBool('highContrast') ?? false;
    language = prefs.getString('language') ?? 'es';
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    await prefs.setDouble('textScale', textScale);
    await prefs.setBool('reduceAnimations', reduceAnimations);
    await prefs.setBool('highContrast', highContrast);
    await prefs.setString('language', language);
  }

  void toggleDarkMode(bool value) {
    isDarkMode = value;
    _savePreferences();
    notifyListeners();
  }

  void updateTextScale(double value) {
    textScale = value;
    _savePreferences();
    notifyListeners();
  }

  void toggleReduceAnimations(bool value) {
    reduceAnimations = value;
    _savePreferences();
    notifyListeners();
  }

  void toggleHighContrast(bool value) {
    highContrast = value;
    _savePreferences();
    notifyListeners();
  }

  void changeLanguage(String value) {
    language = value;
    _savePreferences();
    notifyListeners();
  }
}
