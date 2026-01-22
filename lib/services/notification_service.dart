import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      // Define fuso horário padrão (São Paulo)
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
    } catch (e) {
      print("Erro fuso horário: $e");
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Permissão explícita para Android 13+
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
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
    
    // --- CORREÇÃO CRÍTICA AQUI ---
    // Usamos um ID NOVO ('garden_alarm_v3_popup') para garantir que o Android
    // recrie o canal com IMPORTANCE_MAX. Se usar o ID antigo, ele mantém a config antiga.
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'garden_alarm_v3_popup', 
      'Alarmes GardenMe Urgente', 
      channelDescription: 'Notificações de alta prioridade para cuidados',
      importance: Importance.max, // Garante o Pop-up na tela
      priority: Priority.high,    // Garante topo da lista
      ticker: 'Hora de cuidar da planta!',
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,     // Permite acordar a tela em alguns casos
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidDetails);

    for (int dia in diasDaSemana) {
      // Cria um ID único combinando ID do alarme + Dia da semana
      int notificationId = int.parse("$id$dia");

      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          titulo,
          corpo,
          _nextInstanceOfDayAndTime(dia, hora, minuto),
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Funciona no modo Doze
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
        print("Alarme agendado ($notificationId): Dia $dia às $hora:$minuto");
      } catch (e) {
        print("Erro ao agendar notificação: $e");
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