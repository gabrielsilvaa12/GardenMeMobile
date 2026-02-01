import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/pages/login.dart';
import 'package:gardenme/services/notification_service.dart';
import 'package:gardenme/services/alarme_service.dart';

enum ThemeOption { claro, escuro, folha }

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  ThemeOption _selectedTheme = ThemeOption.folha;
  bool _notificacoesAtivas = false; // Valor inicial temporário
  bool _alertasClimaticos = true;
  bool _carregando = true; // Para evitar "piscar" o botão

  @override
  void initState() {
    super.initState();
    _carregarPreferencias();
  }

  /// Lê a configuração salva no celular ao abrir a tela
  Future<void> _carregarPreferencias() async {
    // 1. O que o usuário salvou no App? (SharedPreferences)
    bool ativoNoApp = await NotificationService().getAppNotificationStatus();
    // 2. O Android/iOS permite notificações?
    bool permitidoSistema = await NotificationService().verificarPermissoesSistema();

    if (mounted) {
      setState(() {
        // O botão só fica LIGADO se o usuário quis (ativoNoApp) E o sistema permitiu
        _notificacoesAtivas = ativoNoApp && permitidoSistema;
        _carregando = false;
      });
    }
  }

  Future<void> _handleNotificationToggle(bool newValue) async {
    if (newValue) {
      // --- USUÁRIO QUER LIGAR ---
      // 1. Verifica permissão do sistema
      bool permitido = await NotificationService().verificarPermissoesSistema();
      
      // 2. Se não tem, pede (usando o método novo do service)
      if (!permitido) {
        permitido = await NotificationService().solicitarPermissoes();
      }

      // 3. Se agora tem permissão
      if (permitido) {
        await NotificationService().setAppNotificationStatus(true); // Salva TRUE
        setState(() => _notificacoesAtivas = true);
        
        // Importante: Reagendar alarmes que estavam "silenciados"
        await AlarmeService().reagendarTodosAlarmes(); 
      } else {
        // Se usuário negou a permissão do sistema, força botão desligado
        setState(() => _notificacoesAtivas = false);
      }
    } else {
      // --- USUÁRIO QUER DESLIGAR ---
      await NotificationService().setAppNotificationStatus(false); // Salva FALSE
      setState(() => _notificacoesAtivas = false);
      
      // Cancela tudo imediatamente
      await NotificationService().cancelarTodasNotificacoes(); 
    }
  }

  // --- Widgets Auxiliares ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(title, style: const TextStyle(color: Color(0xfff2f2f2), fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDivider() {
    return Divider(color: const Color(0xfff2f2f2).withOpacity(0.5), height: 30, thickness: 1);
  }

  Widget _buildThemeOption(ThemeOption value, String title) {
    return RadioListTile<ThemeOption>(
      title: Text(title, style: const TextStyle(color: Color(0xfff2f2f2), fontSize: 16)),
      value: value,
      groupValue: _selectedTheme,
      onChanged: (ThemeOption? newValue) {
        if (newValue != null) setState(() => _selectedTheme = newValue);
      },
      activeColor: const Color(0xfff2f2f2),
      fillColor: WidgetStateProperty.resolveWith((states) => const Color(0xfff2f2f2)),
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildNotificationOption(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Color(0xfff2f2f2), fontSize: 16)),
      value: value,
      onChanged: onChanged,
      activeTrackColor: const Color(0xFFA7C957),
      activeColor: const Color(0xfff2f2f2),
      inactiveThumbColor: const Color(0xfff2f2f2),
      inactiveTrackColor: Colors.grey.shade500,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildLinkText(String text, VoidCallback onTap, {Color color = const Color(0xFFA7C957), IconData? icone}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icone != null) ...[Icon(icone, color: color, size: 20), const SizedBox(width: 8)],
            Text(text, style: TextStyle(color: color, decoration: TextDecoration.underline, decorationColor: color, fontSize: 16)),
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
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 30),
            Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text(conteudo, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA7C957), foregroundColor: const Color(0xFF3A5A40)),
              child: const Text("Entendi", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return curvedBackground(
      child: _carregando 
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(25, 24, 25, 150),
          child: Center(
            child: Container(
              width: 364,
              decoration: BoxDecoration(
                color: const Color(0xff588157),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
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
                      _handleNotificationToggle, 
                    ),
                    _buildNotificationOption(
                      "Alertas climáticos",
                      _alertasClimaticos,
                      (v) => setState(() => _alertasClimaticos = v),
                    ),
                    _buildDivider(),

                    _buildSectionTitle("Sobre o GardenMe"),
                    _buildLinkText("Termos de Uso", () => _mostrarInfoModal(context, "Termos de Uso", "Ao utilizar o GardenMe...")),
                    _buildLinkText("Política de Privacidade", () => _mostrarInfoModal(context, "Privacidade", "Os teus dados...")),
                    const SizedBox(height: 25),
                    Center(
                      child: _buildLinkText(
                        "Sair da Conta",
                        () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const MyLogin()),
                              (route) => false,
                            );
                          }
                        },
                        color: Colors.redAccent,
                        icone: Icons.logout,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Center(child: Text("Versão 1.0.0", style: TextStyle(color: Colors.white38, fontSize: 12))),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}