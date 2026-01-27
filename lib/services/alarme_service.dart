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

    // 1. Tenta Agendar
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
      print("Aviso notificação: $e");
    }

    // 2. Salva no Banco
    await docRef.set(novoAlarme.toMap());
  }

  // --- NOVO MÉTODO PARA O TOGGLE ---
  Future<void> alternarStatus(Alarme alarme, bool novoStatus, String nomePlanta) async {
    if (_userId == null) return;

    // 1. Atualiza no Firestore
    await _alarmesRef.doc(alarme.id).update({'ativo': novoStatus});

    // 2. Gerencia a Notificação Local
    if (novoStatus) {
      // Reativa a notificação
      await _notificationService.agendarNotificacaoSemanal(
        id: alarme.notificationId,
        titulo: "Hora de cuidar da $nomePlanta! 🌱",
        corpo: "Seu lembrete de ${alarme.tipo}",
        hora: alarme.hora,
        minuto: alarme.minuto,
        diasDaSemana: alarme.diasSemana,
      );
    } else {
      // Cancela a notificação
      await _notificationService.cancelarNotificacao(alarme.notificationId, alarme.diasSemana);
    }
  }

  Future<void> deletarAlarme(Alarme alarme) async {
    if (_userId == null) return;
    await _alarmesRef.doc(alarme.id).delete();
    await _notificationService.cancelarNotificacao(alarme.notificationId, alarme.diasSemana);
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