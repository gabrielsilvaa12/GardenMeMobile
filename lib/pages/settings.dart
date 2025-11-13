import 'package:flutter/material.dart';
import 'package:gardenme/components/curved_background.dart';

// 1. Defini um enum para guardar as opções de tema de forma segura
enum ThemeOption { claro, escuro, folha }

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // 2. Variáveis de estado para guardar os valores selecionados
  ThemeOption _selectedTheme = ThemeOption.folha;
  bool _notificacoesAtivas = true;
  bool _alertasClimaticos = true;

  // --- Helper para construir os RadioListTiles (evita repetição) ---
  Widget _buildThemeOption(ThemeOption value, String title) {
    return RadioListTile<ThemeOption>(
      title: Text(
        title,
        style: TextStyle(color: Color(0xfff2f2f2), fontSize: 18),
      ),
      value: value,
      groupValue: _selectedTheme,
      onChanged: (ThemeOption? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedTheme = newValue;
          });
          // Você pode adicionar sua lógica de mudança de tema aqui
          // print("Tema selecionado: $_selectedTheme");
        }
      },
      // Estilização para bater com a imagem
      activeColor: Color(0xFF3A5A40), // Cor da bolinha interna
      fillColor: MaterialStateProperty.all(Color(0xfff2f2f2)), // Cor do círculo
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
    );
  }

  // --- Helper para construir os SwitchListTiles (evita repetição) ---
  Widget _buildNotificationOption(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(color: Color(0xfff2f2f2), fontSize: 18),
      ),
      value: value,
      onChanged: (bool newValue) {
        setState(() {
          onChanged(newValue);
        });
        // Lógica futura:
        // print("$title: $newValue");
      },
      // Estilização para bater com a imagem
      activeTrackColor: Color(0xFFa7c957),
      activeColor: Color(0xfff2f2f2),
      inactiveThumbColor: Color(0xfff2f2f2),
      inactiveTrackColor: Colors.grey.shade700,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return curvedBackground(
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 350, // Largura fixa como ajustamos antes
            decoration: BoxDecoration(
              color: const Color(0xff588157),
              borderRadius: BorderRadius.circular(20), // Borda arredondada
            ),
            child: Padding(
              // 3. Ajustei o padding para ficar mais parecido com a imagem
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Seção TEMA ---
                  const Text(
                    "Tema",
                    style: TextStyle(
                      color: Color(0xfff2f2f2),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildThemeOption(ThemeOption.claro, "Claro"),
                  _buildThemeOption(ThemeOption.escuro, "Escuro"),
                  _buildThemeOption(ThemeOption.folha, "Folha"),

                  // --- Divisor ---
                  Divider(
                    color: Color(0xfff2f2f2).withOpacity(0.4),
                    height: 40,
                    thickness: 1,
                  ),

                  // --- Seção NOTIFICAÇÕES ---
                  const Text(
                    "Notificações",
                    style: TextStyle(
                      color: Color(0xfff2f2f2),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildNotificationOption(
                    "Ativar notificações",
                    _notificacoesAtivas,
                    // Atualiza a variável de estado
                    (newValue) => _notificacoesAtivas = newValue,
                  ),
                  _buildNotificationOption(
                    "Alertas climáticos",
                    _alertasClimaticos,
                    // Atualiza a variável de estado
                    (newValue) => _alertasClimaticos = newValue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
