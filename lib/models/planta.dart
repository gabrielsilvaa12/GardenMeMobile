class Planta {
  final String id;
  final String nome;
  final String? imagemUrl;
  final bool rega; // Status do checkbox
  
  // Campos vindos da API
  final String? estacaoIdeal;
  final String? regaDica;
  final String? tipoTerra;
  final String? dicaFertilizante;

  Planta({
    required this.id,
    required this.nome,
    this.imagemUrl,
    this.rega = false,
    this.estacaoIdeal,
    this.regaDica,
    this.tipoTerra,
    this.dicaFertilizante,
  });

  // Converte do Firebase para o Objeto
  factory Planta.fromMap(Map<String, dynamic> map) {
    return Planta(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      imagemUrl: map['imagem_url'],
      rega: map['rega'] ?? false,
      estacaoIdeal: map['estacao_ideal'],
      regaDica: map['rega_dica'],
      tipoTerra: map['tipo_terra'],
      dicaFertilizante: map['dica_fertilizante'],
    );
  }

  // Converte do Objeto para o Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'imagem_url': imagemUrl,
      'rega': rega,
      'estacao_ideal': estacaoIdeal,
      'rega_dica': regaDica,
      'tipo_terra': tipoTerra,
      'dica_fertilizante': dicaFertilizante,
    };
  }
}