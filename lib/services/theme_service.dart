import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeOption { claro, escuro }

class ThemeService extends ChangeNotifier {
  static final ThemeService instance = ThemeService._internal();

  factory ThemeService() {
    return instance;
  }

  ThemeService._internal();

  ThemeOption _currentTheme = ThemeOption.claro;

  ThemeOption get currentTheme => _currentTheme;

  ThemeData getThemeData() {
    // --- TEMA CLARO ---
    final themeClaro = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFa7c957),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3A5A40),
        primary: const Color(0xFF3A5A40),
      ),
    );

    // --- TEMA ESCURO ---
    final themeEscuro = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF344e41),
      
      // CORREÇÃO DOS INPUTS:
      // Como seus inputs têm fundo claro (#f2f2f2) fixo no código, 
      // precisamos forçar o texto padrão a ser escuro, senão o Flutter
      // usa branco (padrão do modo escuro) e o texto "some".
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF344e41)), 
        bodyMedium: TextStyle(color: Color(0xFF344e41)), 
        titleMedium: TextStyle(color: Color(0xFF344e41)),
      ),
      
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: const Color(0xFF386641),
        primary: const Color(0xFF386641),
      ),
    );

    switch (_currentTheme) {
      case ThemeOption.claro:
        return themeClaro;
      case ThemeOption.escuro:
        return themeEscuro;
    }
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_option') ?? ThemeOption.claro.index;
    
    if (themeIndex >= 0 && themeIndex < ThemeOption.values.length) {
      _currentTheme = ThemeOption.values[themeIndex];
    } else {
      _currentTheme = ThemeOption.claro;
    }
    notifyListeners();
  }

  Future<void> setTheme(ThemeOption option) async {
    if (_currentTheme == option) return;

    _currentTheme = option;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_option', option.index);
  }
}