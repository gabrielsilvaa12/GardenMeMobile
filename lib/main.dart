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

  runApp(const MyApp());
}