class Usuario {
  final String id;
  final String nome;
  final String? sobrenome;
  final String email;
  final String? telefone;
  final String? fotoUrl;
  final String nivel;
  final int pontos;

  Usuario({
    required this.id,
    required this.nome,
    this.sobrenome,
    required this.email,
    this.telefone,
    this.fotoUrl,
    this.nivel = 'Iniciante',
    this.pontos = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'sobrenome': sobrenome,
      'email': email,
      'telefone': telefone,
      'foto_url': fotoUrl,
      'nivel': nivel,
      'pontos': pontos,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      sobrenome: map['sobrenome'],
      email: map['email'] ?? '',
      telefone: map['telefone'],
      fotoUrl: map['foto_url'],
      nivel: map['nivel'] ?? 'Iniciante',
      pontos: map['pontos'] ?? 0,
    );
  }
}
