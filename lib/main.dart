import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gardenme/pages/login.dart';
import 'package:gardenme/pages/main_page.dart';
import 'package:gardenme/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp();

  await Firebase.initializeApp();

  final notificationService = NotificationService();
  await notificationService.init();

  // É recomendável pedir permissões aqui ou na tela inicial.
  // Mantendo aqui conforme seu código original:
  await notificationService.requestPermissions();

  // A CORREÇÃO PRINCIPAL ESTÁ AQUI:
  // Você precisa chamar runApp para iniciar a interface do aplicativo
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GardenMe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3A5A40),
        ),
        useMaterial3: true,
      ),
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
  }
}
