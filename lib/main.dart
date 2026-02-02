import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gardenme/pages/login.dart';
import 'package:gardenme/pages/main_page.dart';
import 'package:gardenme/services/notification_service.dart';
import 'package:gardenme/services/theme_service.dart'; // Importação do serviço

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp();

  // Inicializa o serviço de notificações
  final notificationService = NotificationService();
  await notificationService.init();

  // Pede permissão logo ao abrir (opcional, conforme sua lógica original)
  await notificationService.solicitarPermissoes();

  // Carrega o tema salvo ANTES de rodar a UI
  await ThemeService.instance.loadTheme();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder ouve as mudanças no ThemeService e reconstrói o MaterialApp
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'GardenMe',
          debugShowCheckedModeBanner: false,
          
          // O tema agora vem dinamicamente do serviço
          theme: ThemeService.instance.getThemeData(),

          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF3A5A40),
                    ),
                  ),
                );
              }

              if (snapshot.hasData) {
                return const MainPage();
              }

              return const MyLogin();
            },
          ),
        );
      },
    );
  }
}