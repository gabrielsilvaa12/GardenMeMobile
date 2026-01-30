class Alarme {
  final String id; // ID do documento Firebase
  final int notificationId; // ID numérico único para o sistema de notificação local
  final String plantaId;
  final String tipo; // "Rega", "Fertilização", "Poda"
  final int hora;
  final int minuto;
  final List<int> diasSemana; // [1, 2, ... 7] onde 1 = Segunda
  final bool ativo;

  Alarme({
    required this.id,
    required this.notificationId,
    required this.plantaId,
    required this.tipo,
    required this.hora,
    required this.minuto,
    required this.diasSemana,
    this.ativo = true,
  });

  // Converter para Map (Salvar no Firebase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'notification_id': notificationId,
      'planta_id': plantaId,
      'tipo': tipo,
      'hora': hora,
      'minuto': minuto,
      'dias_semana': diasSemana,
      'ativo': ativo,
    };
  }

  // Criar a partir do Map (Ler do Firebase)
  factory Alarme.fromMap(Map<String, dynamic> map) {
    return Alarme(
      id: map['id'] ?? '',
      notificationId: map['notification_id'] ?? 0,
      plantaId: map['planta_id'] ?? '',
      tipo: map['tipo'] ?? 'Rega',
      hora: map['hora'] ?? 8,
      minuto: map['minuto'] ?? 0,
      diasSemana: List<int>.from(map['dias_semana'] ?? []),
      ativo: map['ativo'] ?? true,
    );
  }
  
  // Helper para exibir hora formatada na tela (ex: "08:05")
  String get horarioFormatado {
    String h = hora.toString().padLeft(2, '0');
    String m = minuto.toString().padLeft(2, '0');
    return "$h:$m";
  }
}