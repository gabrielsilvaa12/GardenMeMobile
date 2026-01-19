import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io'; // Para verificar Platform

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Timezone
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
    } catch (e) {
      print("Erro ao definir fuso horário (usando UTC como fallback): $e");
    }

    // 2. Configurações Android/iOS
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // --- NOVO MÉTODO: Pedir Permissão (Crucial para Android 13+) ---
  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> agendarNotificacaoSemanal({
    required int id,
    required String titulo,
    required String corpo,
    required int hora,
    required int minuto,
    required List<int> diasDaSemana,
  }) async {
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'garden_alarm_channel', 
      'Lembretes do Jardim', 
      channelDescription: 'Notificações de rega e cuidados',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidDetails);

    for (int dia in diasDaSemana) {
      int notificationId = int.parse("$id$dia");

      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          titulo,
          corpo,
          _nextInstanceOfDayAndTime(dia, hora, minuto),
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      } catch (e) {
        print("Erro ao agendar notificação ID $notificationId: $e");
        rethrow; // Repassa o erro para ser tratado no Service
      }
    }
  }

  Future<void> cancelarNotificacao(int idAlarme, List<int> diasDaSemana) async {
    for (int dia in diasDaSemana) {
      try {
        int notificationId = int.parse("$idAlarme$dia");
        await flutterLocalNotificationsPlugin.cancel(notificationId);
      } catch (_) {}
    }
  }

  tz.TZDateTime _nextInstanceOfDayAndTime(int dayOfWeek, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}