import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Agora só existem duas opções
enum ThemeOption { claro, escuro }

class ThemeService extends ChangeNotifier {
  static final ThemeService instance = ThemeService._internal();

  factory ThemeService() {
    return instance;
  }

  ThemeService._internal();

  // O padrão inicial agora é 'claro' (que contém as cores do antigo 'folha')
  ThemeOption _currentTheme = ThemeOption.claro;

  ThemeOption get currentTheme => _currentTheme;

  ThemeData getThemeData() {
    // --- TEMA CLARO (O seu padrão Verde) ---
    // Topo (Fundo): #a7c957
    // Baixo (Container): #3A5A40
    final themeClaro = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      // Define a cor de fundo da tela (usado pelo curvedBackground)
      scaffoldBackgroundColor: const Color(0xFFa7c957),
      // Define as cores principais (usado pelo Container de baixo e botões)
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3A5A40),
        primary: const Color(0xFF3A5A40),
      ),
    );

    // --- TEMA ESCURO (Novas cores) ---
    // Topo (Fundo): #344e41
    // Baixo (Container): #386641
    final themeEscuro = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF344e41),
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
    // Tenta carregar o índice salvo. Se não existir, usa 0 (claro).
    final themeIndex = prefs.getInt('theme_option') ?? ThemeOption.claro.index;
    
    // Verifica se o índice salvo ainda é válido (ex: se o usuário tinha 'folha' salvo como índice 2,
    // agora só temos até o índice 1. Nesse caso, voltamos para o claro).
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