import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gardenme/components/curved_background.dart';

enum ThemeOption { claro, escuro, folha }

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  ThemeOption _selectedTheme = ThemeOption.folha;
  bool _notificacoesAtivas = true;
  bool _alertasClimaticos = true;

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
      activeColor: const Color(0xfff2f2f2),
      fillColor: WidgetStateProperty.resolveWith(
        (states) => const Color(0xfff2f2f2),
      ),
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

  Widget _buildLinkText(
    String text,
    VoidCallback onTap, {
    Color color = const Color(0xFFA7C957),
    IconData? icone,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icone != null) ...[
              Icon(icone, color: color, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                color: color,
                decoration: TextDecoration.underline,
                decorationColor: color,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarInfoModal(BuildContext context, String titulo, String conteudo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        decoration: const BoxDecoration(
          color: Color(0xff588157),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              titulo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              conteudo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA7C957),
                foregroundColor: const Color(0xFF3A5A40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                minimumSize: const Size(150, 45),
              ),
              child: const Text(
                "Entendi",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return curvedBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(25, 24, 25, 150),
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
                  _buildSectionTitle("Tema"),
                  _buildThemeOption(ThemeOption.claro, "Claro"),
                  _buildThemeOption(ThemeOption.escuro, "Escuro"),
                  _buildThemeOption(ThemeOption.folha, "Folha"),

                  _buildDivider(),

                  _buildSectionTitle("Notificações"),
                  _buildNotificationOption(
                    "Ativar notificações",
                    _notificacoesAtivas,
                    (v) => setState(() => _notificacoesAtivas = v),
                  ),
                  _buildNotificationOption(
                    "Alertas climáticos",
                    _alertasClimaticos,
                    (v) => setState(() => _alertasClimaticos = v),
                  ),

                  _buildDivider(),

                  _buildSectionTitle("Sobre o GardenMe"),
                  _buildLinkText("Termos de Uso", () {
                    _mostrarInfoModal(
                      context,
                      "Termos de Uso",
                      "Ao utilizar o GardenMe, concordas em cuidar bem das tuas plantas e espalhar o verde pela comunidade.",
                    );
                  }),
                  _buildLinkText("Política de Privacidade", () {
                    _mostrarInfoModal(
                      context,
                      "Privacidade",
                      "Os teus dados são encriptados e utilizados apenas para melhorar a tua experiência de jardinagem.",
                    );
                  }),

                  const SizedBox(height: 25),
                  Center(
                    child: _buildLinkText(
                      "Sair da Conta",
                      () async {
                        await FirebaseAuth.instance.signOut();
                      },
                      color: Colors.redAccent,
                      icone: Icons.logout,
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Center(
                    child: Text(
                      "Versão 1.0.0",
                      style: TextStyle(color: Colors.white38, fontSize: 12),
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
