import 'package:cloud_firestore/cloud_firestore.dart';

class Planta {
  final String id;
  final String uidUsuario;
  final String nome;
  final String? imagemUrl;
  final String status;
  final bool rega;
  final bool fertilizado;
  final DateTime? horaDoDia;
  
  // Novos campos do Bloco 2 (Dados da API)
  final String? estacaoIdeal;     // Ex: "Primavera"
  final String? tipoTerra;        // Ex: "Terra Vegetal Drenável"
  final String? dicaFertilizante; // Ex: "NPK 10-10-10 a cada mês"
  final String? regaDica;         // Ex: "Deixar o solo secar antes de regar"
  final int intervaloRega;        // Em dias (calculado via API)

  Planta({
    required this.id,
    required this.uidUsuario,
    required this.nome,
    this.imagemUrl,
    this.status = 'Saudável',
    this.rega = false,
    this.fertilizado = false,
    this.horaDoDia,
    this.estacaoIdeal,
    this.tipoTerra,
    this.dicaFertilizante,
    this.regaDica,
    this.intervaloRega = 7, // Padrão semanal caso não venha da API
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid_usuario': uidUsuario,
      'nome': nome,
      'imagem_url': imagemUrl,
      'status': status,
      'rega': rega,
      'fertilizado': fertilizado,
      'hora_do_dia': horaDoDia != null ? Timestamp.fromDate(horaDoDia!) : null,
      // Novos campos
      'estacao_ideal': estacaoIdeal,
      'tipo_terra': tipoTerra,
      'dica_fertilizante': dicaFertilizante,
      'rega_dica': regaDica,
      'intervalo_rega': intervaloRega,
    };
  }

  factory Planta.fromMap(Map<String, dynamic> map, String docId) {
    return Planta(
      id: docId,
      uidUsuario: map['uid_usuario'] ?? '',
      nome: map['nome'] ?? '',
      imagemUrl: map['imagem_url'],
      status: map['status'] ?? 'Saudável',
      rega: map['rega'] ?? false,
      fertilizado: map['fertilizado'] ?? false,
      horaDoDia: map['hora_do_dia'] != null
          ? (map['hora_do_dia'] as Timestamp).toDate()
          : null,
      estacaoIdeal: map['estacao_ideal'],
      tipoTerra: map['tipo_terra'],
      dicaFertilizante: map['dica_fertilizante'],
      regaDica: map['rega_dica'],
      intervaloRega: map['intervalo_rega'] ?? 7,
    );
  }
}