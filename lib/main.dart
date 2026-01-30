import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gardenme/app.dart';
import 'package:gardenme/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp();

  // 🔔 Notificações
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GardenMe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3A5A40)),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF3A5A40)),
              ),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            return const MainPage();
          }

          return const MyLogin();
        },
      ),
    );
  }
}
