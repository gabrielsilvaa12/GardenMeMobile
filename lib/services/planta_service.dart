import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gardenme/models/planta.dart';

class PlantaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _plantasRef {
    if (_userId == null) throw Exception("Usuário não logado");
    return _firestore.collection('usuarios').doc(_userId).collection('plantas');
  }

  // Busca alarmes para verificar vencimento
  CollectionReference get _alarmesRef {
    if (_userId == null) throw Exception("Usuário não logado");
    return _firestore.collection('usuarios').doc(_userId).collection('alarmes');
  }

  Future<void> adicionarPlanta(String nome, String? imagemUrl, {Map<String, dynamic>? dadosExtras}) async {
    final docRef = _plantasRef.doc();
    
    final planta = Planta(
      id: docRef.id,
      nome: nome,
      imagemUrl: imagemUrl,
      rega: false, // Começa como "Não regada" (Laranja)
      estacaoIdeal: dadosExtras?['estacao_ideal'],
      regaDica: dadosExtras?['rega_dica'],
      tipoTerra: dadosExtras?['tipo_terra'],
      dicaFertilizante: dadosExtras?['dica_fertilizante'],
    );

    await docRef.set(planta.toMap());
  }

  Future<void> atualizarStatus(String plantaId, {required bool rega}) async {
    if (_userId == null) return;

    // 1. Atualiza status da planta
    await _plantasRef.doc(plantaId).update({'rega': rega});

    // 2. Gamificação
    final userDoc = _firestore.collection('usuarios').doc(_userId);
    String hoje = DateTime.now().toString().split(' ')[0];

    if (rega) {
      // --- REGOU (Ganhar Pontos) ---
      final snapshot = await userDoc.get();
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      String? ultimaRega = data['ultima_rega_data'];
      int currentStreak = data['streak_atual'] ?? 0;
      int bestStreak = data['melhor_streak'] ?? 0;

      Map<String, dynamic> updates = {
        'pontos': FieldValue.increment(10),
        'regas_count': FieldValue.increment(1),
      };

      // Streak só conta 1 vez por dia
      if (ultimaRega != hoje) {
        int newStreak = currentStreak + 1;
        updates['streak_atual'] = newStreak;
        updates['ultima_rega_data'] = hoje;

        if (newStreak > bestStreak) {
          updates['melhor_streak'] = newStreak;
        }
      }
      
      await userDoc.set(updates, SetOptions(merge: true));

    } else {
      // --- DESFEZ A REGA (Perder Pontos) ---
      await userDoc.update({
        'pontos': FieldValue.increment(-10),
        'regas_count': FieldValue.increment(-1),
      });
    }
  }

  // --- NOVO: Verifica se o horário do alarme já passou para resetar a planta ---
  // Isso garante que a borda fique LARANJA quando chegar a hora
  Future<void> verificarAlarmesVencidos() async {
    if (_userId == null) return;

    try {
      // Pega todos os alarmes
      final alarmesSnap = await _alarmesRef.get();
      final agora = DateTime.now();
      
      // Mapeia plantaID -> Lista de Alarmes
      Map<String, List<Map<String, dynamic>>> alarmesPorPlanta = {};
      
      for (var doc in alarmesSnap.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String plantaId = data['plantaId'];
        int hora = data['hora'];
        int minuto = data['minuto'];
        List<dynamic> dias = data['diasSemana'] ?? [];

        // Verifica se é hoje e se já passou da hora
        if (dias.contains(agora.weekday)) {
          final horaAlarme = DateTime(agora.year, agora.month, agora.day, hora, minuto);
          // Se já passou da hora do alarme E foi menos de 24h atrás
          if (agora.isAfter(horaAlarme) && agora.difference(horaAlarme).inHours < 12) {
             // Marca que esta planta deveria estar "desregada" (laranja) hoje
             // Você pode refinar essa lógica para ser mais complexa se quiser
             await _plantasRef.doc(plantaId).update({'rega': false});
          }
        }
      }
    } catch (e) {
      print("Erro ao verificar alarmes: $e");
    }
  }

  Future<void> removerPlanta(Planta planta) async {
    if (_userId == null) return;
    await _plantasRef.doc(planta.id).delete();
  }

  Future<void> atualizarPlanta(String plantaId, String novoNome, String? novaImagemPath) async {
    if (_userId == null) return;
    Map<String, dynamic> updateData = {'nome': novoNome};
    if (novaImagemPath != null) updateData['imagem_url'] = novaImagemPath;
    await _plantasRef.doc(plantaId).update(updateData);
  }

  Future<void> atualizarNomePlanta(String plantaId, String novoNome) async {
    if (_userId == null) return;
    await _plantasRef.doc(plantaId).update({'nome': novoNome});
  }

  Stream<List<Planta>> getMinhasPlantas() {
    if (_userId == null) return const Stream.empty();
    return _plantasRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; 
        return Planta.fromMap(data);
      }).toList();
    });
  }
}