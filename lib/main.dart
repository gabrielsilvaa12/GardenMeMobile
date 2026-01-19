import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gardenme/app.dart'; // Certifique-se que seu App widget está aqui
import 'package:gardenme/services/notification_service.dart';
// import 'firebase_options.dart'; // Descomente se usar firebase_options gerado pelo CLI

void main() async {
  // Garante que a engine do Flutter esteja pronta antes de rodar código assíncrono
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inicializa o Firebase
  // Se você usa o arquivo gerado pelo FlutterFire CLI, use:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Caso contrário (setup manual android/ios):
  await Firebase.initializeApp();

  // 2. Inicializa o Sistema de Notificações (Local & Fuso Horário)
  // Isso é crucial para que os alarmes funcionem
  await NotificationService().init();

  runApp(const MyApp());
}