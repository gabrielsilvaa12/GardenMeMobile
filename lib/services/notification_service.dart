import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  // Chave para salvar a preferência no banco local do celular
  static const String _prefsKey = 'notifications_enabled_user_pref';

  /// Inicialização geral
  Future<void> init() async {
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

  /// Verifica se o usuário permitiu notificações DENTRO DO APP (Botão Toggle)
  Future<bool> getAppNotificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Padrão é TRUE (ligado) se nunca tiver sido mexido
    return prefs.getBool(_prefsKey) ?? true;
  }

  /// Salva a escolha do usuário (Ligado ou Desligado)
  Future<void> setAppNotificationStatus(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, enabled);
  }

  /// Verifica se o SISTEMA (Android/iOS) deu permissão
  Future<bool> verificarPermissoesSistema() async {
    return await Permission.notification.isGranted;
  }

  /// Solicita permissão ao sistema (Pop-up nativo)
  Future<bool> solicitarPermissoes() async {
    final status = await Permission.notification.request();
    // Se for Android 13+, pede permissão de alarmes exatos também
    if (Platform.isAndroid) {
        final android = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        await android?.requestExactAlarmsPermission();
    }
    return status.isGranted;
  }

  /// Cancela TODAS as notificações e limpa a fila do sistema
  Future<void> cancelarTodasNotificacoes() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print("Todas as notificações foram canceladas.");
  }

  /// Agendar Notificação (Com verificação de bloqueio)
  Future<void> agendarNotificacaoSemanal({
    required int id,
    required String titulo,
    required String corpo,
    required int hora,
    required int minuto,
    required List<int> diasDaSemana,
  }) async {
    // 🛑 BLOQUEIO CRÍTICO: 
    // Se o usuário desligou o botão no app, NÃO agenda nada, mesmo se for um alarme novo.
    bool appEnabled = await getAppNotificationStatus();
    if (!appEnabled) {
      print("Notificação bloqueada: O botão de notificações está desligado.");
      return; 
    }

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