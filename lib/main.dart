import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gardenme/app.dart'; // Importa o seu MyApp
import 'package:gardenme/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp();

  // Inicializa e configura as Notificações
  final notificationService = NotificationService();
  await notificationService.init();
  
  // É recomendável pedir permissões aqui ou na tela inicial.
  // Mantendo aqui conforme seu código original:
  await notificationService.requestPermissions();

  // A CORREÇÃO PRINCIPAL ESTÁ AQUI:
  // Você precisa chamar runApp para iniciar a interface do aplicativo
  runApp(const MyApp()); 
}