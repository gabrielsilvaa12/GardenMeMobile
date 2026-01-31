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

  /// Inicialização geral
  Future<void> init() async {
    // Timezone
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
    } catch (e) {
      print('Erro ao definir fuso horário: $e');
    }

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await flutterLocalNotificationsPlugin.initialize(settings);

    // 🔥 Canal Android (OBRIGATÓRIO)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'garden_alarm_v3_popup',
      'Alarmes GardenMe Urgente',
      description: 'Notificações de alta prioridade',
      importance: Importance.max,
      playSound: true,
    );

    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);
  }

  /// Permissões Android 13+
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final android =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();
    }
  }

  /// 🔔 NOTIFICAÇÃO DE TESTE (8 SEGUNDOS)
  Future<void> notificarTesteEm8Segundos() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'garden_alarm_v3_popup',
      'Alarmes GardenMe Urgente',
      channelDescription: 'Notificação de teste',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    final tz.TZDateTime scheduledDate =
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 8));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      999999,
      '🔔 TESTE DE NOTIFICAÇÃO',
      'Se você viu isso, o popup está funcionando 🚀',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    print('🧪 Notificação de teste agendada para 8 segundos');
  }

  /// Alarmes semanais reais
  Future<void> agendarNotificacaoSemanal({
    required int id,
    required String titulo,
    required String corpo,
    required int hora,
    required int minuto,
    required List<int> diasDaSemana,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'garden_alarm_v3_popup',
      'Alarmes GardenMe Urgente',
      channelDescription: 'Notificações de alta prioridade',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    for (final dia in diasDaSemana) {
      final int notificationId = (id * 10) + dia;

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        titulo,
        corpo,
        _nextInstanceOfDayAndTime(dia, hora, minuto),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> cancelarNotificacao(int idAlarme, List<int> diasDaSemana) async {
    for (final dia in diasDaSemana) {
      // Use a mesma lógica matemática do agendamento
      final int notificationId = (idAlarme * 10) + dia;
      await flutterLocalNotificationsPlugin.cancel(notificationId);
    }
  }

  tz.TZDateTime _nextInstanceOfDayAndTime(int weekday, int hour, int minute) {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}
