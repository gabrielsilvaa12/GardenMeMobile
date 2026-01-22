import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:gardenme/models/planta.dart';

class PlantaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _plantasRef => _firestore.collection('plantas');
  // CORREÇÃO: Apontando para 'usuarios'
  CollectionReference get _usersRef => _firestore.collection('usuarios');

  // --- GAMIFICAÇÃO ---
  Future<void> _adicionarPontosUsuario(int pontos) async {
    if (_userId == null) return;
    try {
      await _usersRef.doc(_userId).set({
        'pontos': FieldValue.increment(pontos),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Erro ao adicionar pontos: $e");
    }
  }

  Future<void> adicionarPlanta(String nome, String? imagemUrlApi, {Map<String, dynamic>? dadosExtras}) async {
    if (_userId == null) return;
    final docRef = _plantasRef.doc();
    String? finalImageUrl;

    if (imagemUrlApi != null && imagemUrlApi.isNotEmpty) {
      try {
        finalImageUrl = await _salvarImagemNoStorage(imagemUrlApi, docRef.id);
      } catch (e) {
        finalImageUrl = imagemUrlApi;
      }
    }

    final novaPlanta = Planta(
      id: docRef.id,
      uidUsuario: _userId!,
      nome: nome,
      imagemUrl: finalImageUrl,
      status: 'Saudável',
      rega: false,
      fertilizado: false,
      horaDoDia: DateTime.now(),
      estacaoIdeal: dadosExtras?['estacao_ideal'],
      tipoTerra: dadosExtras?['tipo_terra'],
      dicaFertilizante: dadosExtras?['dica_fertilizante'],
      regaDica: dadosExtras?['rega_dica'],
      intervaloRega: dadosExtras?['intervalo_rega'] ?? 7,
    );

    await docRef.set(novaPlanta.toMap());
    // CORREÇÃO: Adiciona 50 pontos
    await _adicionarPontosUsuario(50);
  }

  Future<void> editarPlanta(Planta planta, String novoNome, File? novaImagemFile) async {
    if (_userId == null) return;
    String? novaUrl = planta.imagemUrl;

    if (novaImagemFile != null) {
      try {
        final storageRef = _storage.ref().child('plantas/$_userId/${planta.id}.jpg');
        final UploadTask task = storageRef.putFile(novaImagemFile);
        final TaskSnapshot snapshot = await task;
        novaUrl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        print("Erro ao atualizar imagem: $e");
        throw Exception("Não foi possível salvar a nova foto.");
      }
    }

    await _plantasRef.doc(planta.id).update({
      'nome': novoNome,
      'imagem_url': novaUrl,
    });
  }

  Future<void> removerPlanta(Planta planta) async {
    if (_userId == null) return;
    try {
      if (planta.imagemUrl != null && planta.imagemUrl!.contains('firebasestorage')) {
        try {
          final storageRef = _storage.ref().child('plantas/$_userId/${planta.id}.jpg');
          await storageRef.delete();
        } catch (_) {}
      }
      await _plantasRef.doc(planta.id).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<String> _salvarImagemNoStorage(String urlApi, String plantaId) async {
    final http.Response response = await http.get(Uri.parse(urlApi));
    if (response.statusCode == 200) {
      final Uint8List data = response.bodyBytes;
      final storageRef = _storage.ref().child('plantas/$_userId/$plantaId.jpg');
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final UploadTask task = storageRef.putData(data, metadata);
      final TaskSnapshot snapshot = await task;
      return await snapshot.ref.getDownloadURL();
    } else {
      throw Exception("Falha no download da imagem da API");
    }
  }

  Stream<List<Planta>> getMinhasPlantas() {
    if (_userId == null) return const Stream.empty();
    return _plantasRef.where('uid_usuario', isEqualTo: _userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Planta.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  Future<void> atualizarStatus(String plantaId, {bool? rega, bool? fertilizado}) async {
    Map<String, dynamic> updates = {};
    if (rega != null) {
      updates['rega'] = rega;
      if (rega == true) await _adicionarPontosUsuario(10);
    }
    if (fertilizado != null) {
      updates['fertilizado'] = fertilizado;
      if (fertilizado == true) await _adicionarPontosUsuario(20);
    }
    await _plantasRef.doc(plantaId).update(updates);
  }
}