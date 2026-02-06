import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gardenme/models/alarme.dart';
import 'package:gardenme/models/planta.dart';
import 'package:gardenme/services/alarme_service.dart';

class PlantaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _plantasRef {
    if (_userId == null) throw Exception("Usuário não logado");
    return _firestore.collection('usuarios').doc(_userId).collection('plantas');
  }

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
      rega: false,
      dataUltimaRega: null,
      dataCriacao: DateTime.now(),
      estacaoIdeal: dadosExtras?['estacao_ideal'],
      regaDica: dadosExtras?['rega_dica'],
      tipoTerra: dadosExtras?['tipo_terra'],
      dicaFertilizante: dadosExtras?['dica_fertilizante'],
    );

    await docRef.set(planta.toMap());

    if (_userId != null) {
      await _firestore.collection('usuarios').doc(_userId).update({
        'plantas_count': FieldValue.increment(1),
      });
    }
  }

  String _calcularNivelNome(int pontos) {
    if (pontos < 100) return "Regador Iniciante";
    if (pontos < 200) return "Dedo Verde em Treinamento";
    if (pontos < 400) return "Encantador(a) de Plantas";
    if (pontos < 600) return "Mago Verde Certificado";
    if (pontos < 800) return "Guardião Supremo do Jardim";
    return "Lenda do Dedo Verde"; 
  }

  Future<void> atualizarStatus(String plantaId, {required bool rega}) async {
    if (_userId == null) return;

    // 1. Atualiza status da planta salvando o MOMENTO da rega
    await _plantasRef.doc(plantaId).update({
      'rega': rega,
      'data_ultima_rega': rega ? DateTime.now() : null, 
    });

    // 2. Gamificação
    final userDoc = _firestore.collection('usuarios').doc(_userId);
    String hoje = DateTime.now().toString().split(' ')[0];

    if (rega) {
      final snapshot = await userDoc.get();
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      
      String? ultimaRega = data['ultima_rega_data'];
      int currentStreak = data['streak_atual'] ?? 0;
      int bestStreak = data['melhor_streak'] ?? 0;
      int pontosAtuais = data['pontos'] ?? 0;

      int novosPontos = pontosAtuais + 10;
      String novoNivel = _calcularNivelNome(novosPontos);

      int newStreak = 1; 
      if (ultimaRega != null) {
         DateTime agora = DateTime.now();
         DateTime ultimaData = DateTime.parse(ultimaRega);
         DateTime dataHojeSemHora = DateTime(agora.year, agora.month, agora.day);
         DateTime ultimaDataSemHora = DateTime(ultimaData.year, ultimaData.month, ultimaData.day);
         int diffDias = dataHojeSemHora.difference(ultimaDataSemHora).inDays;

         if (diffDias == 0) {
           newStreak = currentStreak; 
         } else if (diffDias == 1) {
           newStreak = currentStreak + 1; 
         } else {
           newStreak = 1; 
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

  // --- NOVA LÓGICA: Resetar as plantas às 01:00 AM ---
  Future<void> verificarRegasDiarias() async {
    if (_userId == null) return;

    try {
      final plantasSnap = await _plantasRef.get();
      final agora = DateTime.now();
      
      // Define o "horário de corte" (01:00 AM de hoje)
      DateTime corteHoje = DateTime(agora.year, agora.month, agora.day, 1, 0, 0);

      // Se agora ainda for cedo (ex: 00:30), o corte relevante é 01:00 de ONTEM
      if (agora.isBefore(corteHoje)) {
        corteHoje = corteHoje.subtract(const Duration(days: 1));
      }

      for (var doc in plantasSnap.docs) {
        var data = doc.data() as Map<String, dynamic>;
        bool estaRegada = data['rega'] ?? false;
        
        DateTime? ultimaRega;
        if (data['data_ultima_rega'] != null) {
          if (data['data_ultima_rega'] is Timestamp) {
            ultimaRega = (data['data_ultima_rega'] as Timestamp).toDate();
          } else if (data['data_ultima_rega'] is String) {
            ultimaRega = DateTime.tryParse(data['data_ultima_rega']);
          }
        }

        // Se a última rega foi ANTES do corte das 01:00, reseta para Laranja (false)
        if (estaRegada) {
          if (ultimaRega == null || ultimaRega.isBefore(corteHoje)) {
             await _plantasRef.doc(doc.id).update({'rega': false});
          }
        }
      }
    } catch (e) {
      print("Erro ao verificar reset diário das plantas: $e");
    }
  }

  Future<void> removerPlanta(Planta planta) async {
    if (_userId == null) return;
    final AlarmeService alarmeService = AlarmeService();

    try {
      final alarmesSnapshot = await _alarmesRef
          .where('planta_id', isEqualTo: planta.id)
          .get();

      for (var doc in alarmesSnapshot.docs) {
        final alarme = Alarme.fromMap(doc.data() as Map<String, dynamic>);
        await alarmeService.deletarAlarme(alarme);
      }
    } catch (e) {
      print("Erro ao limpar alarmes da planta: $e");
    }

    await _plantasRef.doc(planta.id).delete();
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
      final plantas = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; 
        return Planta.fromMap(data);
      }).toList();

      plantas.sort((a, b) {
        if (a.dataCriacao == null && b.dataCriacao == null) return 0;
        if (a.dataCriacao == null) return -1;
        if (b.dataCriacao == null) return 1;
        return a.dataCriacao!.compareTo(b.dataCriacao!);
      });

      return plantas;
    });
  }
}