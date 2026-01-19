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
    return _firestore.collection('users').doc(_userId).collection('alarmes');
  }

  Future<void> criarAlarme({
    required String plantaId,
    required String nomePlanta,
    required String tipo,
    required int hora,
    required int minuto,
    required List<int> diasSemana,
  }) async {
    if (_userId == null) throw Exception("Usuário não logado");

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

    // 1. Tenta Agendar a Notificação no Celular PRIMEIRO
    // Se falhar aqui (permissão negada), a gente ainda salva no banco mas avisa.
    try {
      await _notificationService.agendarNotificacaoSemanal(
        id: notifId,
        titulo: "Hora de cuidar da $nomePlanta! 🌱",
        corpo: "Lembrete: $tipo agendada para agora.",
        hora: hora,
        minuto: minuto,
        diasDaSemana: diasSemana,
      );
    } catch (e) {
      print("Aviso: Falha ao agendar notificação local: $e");
      // Não damos 'rethrow' aqui para permitir salvar no banco mesmo sem notificação
    }

    // 2. Salva no Banco de Dados (Firestore)
    // Isso garante que apareça na lista
    await docRef.set(novoAlarme.toMap());
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