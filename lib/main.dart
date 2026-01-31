import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
<<<<<<< HEAD
import 'package:gardenme/app.dart'; // Importa o seu MyApp
=======
import 'package:gardenme/pages/login.dart';
import 'package:gardenme/pages/main_page.dart';
>>>>>>> 4bfa6bec39fc571466eb05f07e627f03dce1231c
import 'package:gardenme/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

<<<<<<< HEAD
  // Inicializa o Firebase
  await Firebase.initializeApp();

  // Inicializa e configura as Notificações
=======
  await Firebase.initializeApp();

>>>>>>> 4bfa6bec39fc571466eb05f07e627f03dce1231c
  final notificationService = NotificationService();
  await notificationService.init();
  
  // É recomendável pedir permissões aqui ou na tela inicial.
  // Mantendo aqui conforme seu código original:
  await notificationService.requestPermissions();

<<<<<<< HEAD
  // A CORREÇÃO PRINCIPAL ESTÁ AQUI:
  // Você precisa chamar runApp para iniciar a interface do aplicativo
  runApp(const MyApp()); 
}
=======
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
>>>>>>> 4bfa6bec39fc571466eb05f07e627f03dce1231c
