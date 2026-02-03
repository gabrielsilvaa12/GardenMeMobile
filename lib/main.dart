import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gardenme/pages/login.dart';
import 'package:gardenme/pages/main_page.dart';
import 'package:gardenme/services/notification_service.dart';
import 'package:gardenme/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp();

  // Inicializa o serviço de notificações
  final notificationService = NotificationService();
  await notificationService.init();

  // Pede permissão logo ao abrir
  await notificationService.solicitarPermissoes();

  // Carrega o tema salvo ANTES de rodar a UI
  await ThemeService.instance.loadTheme();

  runApp(const MyApp());
}

// Transformado em StatefulWidget para manter o estado do stream de autenticação
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Cache do stream para evitar recarregamento (flicker) ao mudar o tema
  late final Stream<User?> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = FirebaseAuth.instance.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'GardenMe',
          debugShowCheckedModeBanner: false,
          
          theme: ThemeService.instance.getThemeData(),

          home: StreamBuilder<User?>(
            // Usa o stream armazenado no estado
            stream: _authStream,
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