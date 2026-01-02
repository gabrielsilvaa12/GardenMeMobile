import 'package:flutter/material.dart';
import 'package:gardenme/components/curved_background.dart';

enum ThemeOption { claro, escuro, folha }

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // Variáveis de estado existentes
  ThemeOption _selectedTheme = ThemeOption.folha;
  bool _notificacoesAtivas = true;
  bool _alertasClimaticos = true;

  // Controladores para os campos de senha (Novos)
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  @override
  void dispose() {
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  // --- Widgets Auxiliares ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xfff2f2f2),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: const Color(0xfff2f2f2).withOpacity(0.5),
      height: 30,
      thickness: 1,
    );
  }

  Widget _buildThemeOption(ThemeOption value, String title) {
    return RadioListTile<ThemeOption>(
      title: Text(
        title,
        style: const TextStyle(color: Color(0xfff2f2f2), fontSize: 16),
      ),
      value: value,
      groupValue: _selectedTheme,
      onChanged: (ThemeOption? newValue) {
        if (newValue != null) {
          setState(() => _selectedTheme = newValue);
        }
      },
      activeColor: const Color(
        0xfff2f2f2,
      ), // Mudado para branco/claro conforme imagem
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const Color(0xfff2f2f2); // Borda branca quando selecionado
        }
        return const Color(0xfff2f2f2); // Borda branca quando não selecionado
      }),
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildNotificationOption(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(color: Color(0xfff2f2f2), fontSize: 16),
      ),
      value: value,
      onChanged: (bool newValue) {
        setState(() => onChanged(newValue));
      },
      activeTrackColor: const Color(0xFFA7C957),
      activeColor: const Color(0xfff2f2f2),
      inactiveThumbColor: const Color(0xfff2f2f2),
      inactiveTrackColor: Colors.grey.shade500,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xfff2f2f2),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: true,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintStyle: TextStyle(
                color: Colors.black.withOpacity(0.6),
                fontSize: 14,
                letterSpacing: 2,
              ),
              filled: true,
              fillColor: const Color(0xfff2f2f2),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLinkText(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFA7C957), // Cor esverdeada clara para links
            decoration: TextDecoration.underline,
            decorationColor: Color(0xFFA7C957),
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return curvedBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          bottom: 170,
          top: 24,
        ), // Espaço extra para scroll
        child: Center(
          child: Container(
            width: 364,
            decoration: BoxDecoration(
              color: const Color(0xff588157),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- TEMA ---
                  _buildSectionTitle("Tema"),
                  _buildThemeOption(ThemeOption.claro, "Claro"),
                  _buildThemeOption(ThemeOption.escuro, "Escuro"),
                  _buildThemeOption(ThemeOption.folha, "Folha"),

                  _buildDivider(),

                  // --- NOTIFICAÇÕES ---
                  _buildSectionTitle("Notificações"),
                  _buildNotificationOption(
                    "Ativar notificações",
                    _notificacoesAtivas,
                    (v) => _notificacoesAtivas = v,
                  ),
                  _buildNotificationOption(
                    "Alertas climáticos",
                    _alertasClimaticos,
                    (v) => _alertasClimaticos = v,
                  ),

                  _buildDivider(),

                  // --- SEGURANÇA ---
                  _buildSectionTitle("Segurança"),
                  _buildPasswordField("Senha atual*", _senhaAtualController),
                  _buildPasswordField("Nova senha*", _novaSenhaController),
                  _buildPasswordField(
                    "Confirme a nova senha*",
                    _confirmarSenhaController,
                  ),

                  const SizedBox(height: 10),
                  Center(
                    child: SizedBox(
                      width: 140,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          // Lógica de salvar senha
                          FocusScope.of(context).unfocus(); // Esconde teclado
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA7C957),
                          foregroundColor: const Color(
                            0xFF3A5A40,
                          ), // Cor do texto
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          "Salvar",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
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
