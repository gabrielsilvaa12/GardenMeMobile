import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gardenme/models/alarme.dart';
import 'package:gardenme/services/notification_service.dart';

class AlarmeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _alarmesRef {
    if (_userId == null) throw Exception("Usuário não logado");
    return _firestore.collection('usuarios').doc(_userId).collection('alarmes');
  }

  Future<void> criarAlarme({
    required String plantaId,
    required String nomePlanta,
    required String tipo,
    required int hora,
    required int minuto,
    required List<int> diasSemana,
  }) async {
    if (_userId == null) return;

    final docRef = _alarmesRef.doc();
    final int notifId = Random().nextInt(100000); 

    final novoAlarme = Alarme(
      id: docRef.id,
      notificationId: notifId,
      plantaId: plantaId,
      tipo: tipo,
      hora: hora,
      minuto: minuto,
      diasSemana: diasSemana,
      ativo: true,
    );

    await docRef.set(novoAlarme.toMap());

    // Tenta agendar (será bloqueado pelo NotificationService se o botão estiver OFF)
    try {
      await _notificationService.agendarNotificacaoSemanal(
        id: notifId,
        titulo: "Hora de cuidar da $nomePlanta! 🌱",
        corpo: "Seu lembrete de $tipo",
        hora: hora,
        minuto: minuto,
        diasDaSemana: diasSemana,
      );
    } catch (e) {
      print("Aviso notificação (criar): $e");
    }
  }

  Future<void> editarAlarme({
    required Alarme alarmeAntigo,
    required String nomePlanta,
    required String novoTipo,
    required int novaHora,
    required int novoMinuto,
    required List<int> novosDias,
  }) async {
    if (_userId == null) return;

    final alarmeAtualizado = Alarme(
      id: alarmeAntigo.id,
      notificationId: alarmeAntigo.notificationId,
      plantaId: alarmeAntigo.plantaId,
      tipo: novoTipo,
      hora: novaHora,
      minuto: novoMinuto,
      diasSemana: novosDias,
      ativo: true,
    );

    await _alarmesRef.doc(alarmeAntigo.id).update(alarmeAtualizado.toMap());

    try {
      await _notificationService.cancelarNotificacao(alarmeAntigo.notificationId, alarmeAntigo.diasSemana);
      await _notificationService.agendarNotificacaoSemanal(
        id: alarmeAntigo.notificationId,
        titulo: "Hora de cuidar da $nomePlanta! 🌱",
        corpo: "Seu lembrete de $novoTipo",
        hora: novaHora,
        minuto: novoMinuto,
        diasDaSemana: novosDias,
      );
    } catch (e) {
      print("Erro ao reagendar notificação: $e");
    }
  }

  Future<void> alternarStatus(Alarme alarme, bool novoStatus, String nomePlanta) async {
    if (_userId == null) return;

    await _alarmesRef.doc(alarme.id).update({'ativo': novoStatus});

    try {
      if (novoStatus) {
        await _notificationService.agendarNotificacaoSemanal(
          id: alarme.notificationId,
          titulo: "Hora de cuidar da $nomePlanta! 🌱",
          corpo: "Seu lembrete de ${alarme.tipo}",
          hora: alarme.hora,
          minuto: alarme.minuto,
          diasDaSemana: alarme.diasSemana,
        );
      } else {
        await _notificationService.cancelarNotificacao(alarme.notificationId, alarme.diasSemana);
      }
    } catch (e) {
      print("Erro ao alterar status notificação: $e");
    }
  }

  Future<void> deletarAlarme(Alarme alarme) async {
    if (_userId == null) return;
    await _alarmesRef.doc(alarme.id).delete();
    try {
      await _notificationService.cancelarNotificacao(alarme.notificationId, alarme.diasSemana);
    } catch (e) {
      print("Erro ao cancelar notificação: $e");
    }
  }

  // --- REAGENDAMENTO TOTAL (Chamado ao ligar o botão nas Configurações) ---
  Future<void> reagendarTodosAlarmes() async {
    if (_userId == null) return;

    try {
      // 1. Busca alarmes ativos
      final alarmesSnap = await _alarmesRef.where('ativo', isEqualTo: true).get();
      if (alarmesSnap.docs.isEmpty) return;

      // 2. Busca nomes das plantas
      final plantasSnap = await _firestore.collection('usuarios').doc(_userId).collection('plantas').get();
      final Map<String, String> nomesPlantas = {};
      for (var doc in plantasSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        nomesPlantas[doc.id] = data['nome']?.toString() ?? 'Sua Planta';
      }

      // 3. Reagenda
      for (var doc in alarmesSnap.docs) {
        final alarme = Alarme.fromMap(doc.data() as Map<String, dynamic>);
        final nomePlanta = nomesPlantas[alarme.plantaId] ?? 'Sua Planta';

        await _notificationService.agendarNotificacaoSemanal(
          id: alarme.notificationId,
          titulo: "Hora de cuidar da $nomePlanta! 🌱",
          corpo: "Seu lembrete de ${alarme.tipo}",
          hora: alarme.hora,
          minuto: alarme.minuto,
          diasDaSemana: alarme.diasSemana,
        );
      }
      print("Todos os alarmes foram reagendados com sucesso.");
    } catch (e) {
      print("Erro ao reagendar todos os alarmes: $e");
    }
  }

  Stream<List<Alarme>> getAlarmesDaPlanta(String plantaId) {
    if (_userId == null) return const Stream.empty();
    return _alarmesRef
        .where('planta_id', isEqualTo: plantaId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Alarme.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}