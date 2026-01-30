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

    // 1. Salva a planta
    await docRef.set(planta.toMap());

    // 2. Atualiza a contagem de plantas no perfil do usuário (+1)
    if (_userId != null) {
      await _firestore.collection('usuarios').doc(_userId).update({
        'plantas_count': FieldValue.increment(1),
      });
    }
  }

  // --- ATUALIZADO: NOVOS NÍVEIS DE GAMEFICAÇÃO (6 NÍVEIS) ---
  String _calcularNivelNome(int pontos) {
    if (pontos < 100) return "Regador Iniciante";
    if (pontos < 200) return "Dedo Verde em Treinamento";
    if (pontos < 400) return "Encantador(a) de Plantas";
    if (pontos < 600) return "Mago Verde Certificado";
    if (pontos < 800) return "Guardião Supremo do Jardim";
    return "Lenda do Dedo Verde"; // 800+ pontos
  }

  Future<void> atualizarStatus(String plantaId, {required bool rega}) async {
    if (_userId == null) return;

    // 1. Atualiza status da planta
    await _plantasRef.doc(plantaId).update({'rega': rega});

    // 2. Gamificação
    final userDoc = _firestore.collection('usuarios').doc(_userId);
    String hoje = DateTime.now().toString().split(' ')[0];

    // Se for REGA (True), processa pontos e níveis
    if (rega) {
      final snapshot = await userDoc.get();
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      
      // Recupera dados atuais
      String? ultimaRega = data['ultima_rega_data'];
      int currentStreak = data['streak_atual'] ?? 0;
      int bestStreak = data['melhor_streak'] ?? 0;
      int pontosAtuais = data['pontos'] ?? 0;

      // Calcula novos valores
      int novosPontos = pontosAtuais + 10;
      String novoNivel = _calcularNivelNome(novosPontos);

      // Lógica de Streak (Contagem de dias seguidos)
      int newStreak = 1; 
      if (ultimaRega != null) {
         DateTime agora = DateTime.now();
         DateTime ultimaData = DateTime.parse(ultimaRega);
         DateTime dataHojeSemHora = DateTime(agora.year, agora.month, agora.day);
         DateTime ultimaDataSemHora = DateTime(ultimaData.year, ultimaData.month, ultimaData.day);
         int diffDias = dataHojeSemHora.difference(ultimaDataSemHora).inDays;

         if (diffDias == 0) {
           newStreak = currentStreak; // Já regou hoje, mantém
         } else if (diffDias == 1) {
           newStreak = currentStreak + 1; // Sequência
         } else {
           newStreak = 1; // Quebrou sequência
         }
      }

      Map<String, dynamic> updates = {
        'pontos': novosPontos, 
        'nivel': novoNivel,    
        'regas_count': FieldValue.increment(1),
        'ultima_rega_data': hoje,
        'streak_atual': newStreak,
      };

      if (newStreak > bestStreak) {
        updates['melhor_streak'] = newStreak;
      }
      
      await userDoc.set(updates, SetOptions(merge: true));
    } 
  }

  // --- Verifica se o horário do alarme já passou para resetar a planta ---
  Future<void> verificarAlarmesVencidos() async {
    if (_userId == null) return;

    try {
      final alarmesSnap = await _alarmesRef.get();
      final agora = DateTime.now();
      
      for (var doc in alarmesSnap.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String plantaId = data['plantaId'];
        int hora = data['hora'];
        int minuto = data['minuto'];
        List<dynamic> dias = data['diasSemana'] ?? [];

        if (dias.contains(agora.weekday)) {
          final horaAlarme = DateTime(agora.year, agora.month, agora.day, hora, minuto);
          if (agora.isAfter(horaAlarme) && agora.difference(horaAlarme).inHours < 12) {
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
    
    // 1. Remove a planta
    await _plantasRef.doc(planta.id).delete();

    // 2. Atualiza a contagem de plantas no perfil do usuário (-1)
    await _firestore.collection('usuarios').doc(_userId).update({
      'plantas_count': FieldValue.increment(-1),
    });
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