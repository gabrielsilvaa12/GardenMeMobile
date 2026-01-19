import 'package:flutter/material.dart';
import 'package:gardenme/components/add_alarm_modal.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/models/alarme.dart';
import 'package:gardenme/services/alarme_service.dart';

class AlarmsPage extends StatefulWidget {
  final String plantName;
  final String plantaId; // Necessário para buscar no banco

  const AlarmsPage({
    super.key,
    required this.plantName,
    required this.plantaId,
  });

  @override
  State<AlarmsPage> createState() => _AlarmsPageState();
}

class _AlarmsPageState extends State<AlarmsPage> {
  final AlarmeService _alarmeService = AlarmeService();

  // Função para deletar com confirmação visual
  Future<void> _deletarAlarme(Alarme alarme) async {
    try {
      await _alarmeService.deletarAlarme(alarme);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Alarme removido.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao remover: $e")),
        );
      }
    }
  }

  // Mapa para exibir os dias da semana de forma amigável
  String _formatarDias(List<int> dias) {
    if (dias.length == 7) return "Todos os dias";
    if (dias.isEmpty) return "Sem repetição";
    
    const mapaDias = {1: 'Seg', 2: 'Ter', 3: 'Qua', 4: 'Qui', 5: 'Sex', 6: 'Sáb', 7: 'Dom'};
    // Ordena os dias e mapeia para texto
    dias.sort();
    return dias.map((d) => mapaDias[d]).join(', ');
  }

  void _abrirModalAdicionar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAlarmModal(
        plantaId: widget.plantaId,
        nomePlanta: widget.plantName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFa7c957),
      body: Column(
        children: [
          Expanded(
            child: curvedBackground(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Cabeçalho simples
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF3A5A40)),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            'Alarmes: ${widget.plantName}',
                            style: const TextStyle(
                              color: Color(0xFF3A5A40),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 40), // Espaço para equilibrar o ícone de voltar
                      ],
                    ),
                    
                    const SizedBox(height: 20),

                    // Lista de Alarmes (StreamBuilder)
                    Expanded(
                      child: StreamBuilder<List<Alarme>>(
                        stream: _alarmeService.getAlarmesDaPlanta(widget.plantaId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          if (snapshot.hasError) {
                            return const Center(child: Text("Erro ao carregar alarmes."));
                          }

                          final alarmes = snapshot.data ?? [];

                          if (alarmes.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey[400]),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Nenhum alarme configurado.",
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80), // Espaço para o botão flutuante
                            itemCount: alarmes.length,
                            itemBuilder: (context, index) {
                              final alarme = alarmes[index];
                              return Dismissible(
                                key: Key(alarme.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  color: Colors.redAccent,
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                onDismissed: (direction) {
                                  _deletarAlarme(alarme);
                                },
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFA7C957).withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        alarme.tipo == 'Rega' ? Icons.water_drop : Icons.science,
                                        color: const Color(0xFF386641),
                                      ),
                                    ),
                                    title: Text(
                                      alarme.horarioFormatado,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3A5A40),
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          alarme.tipo.toUpperCase(),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                        Text(
                                          _formatarDias(alarme.diasSemana),
                                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => _deletarAlarme(alarme),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      
      // Botão Flutuante para Adicionar
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirModalAdicionar(context),
        backgroundColor: const Color(0xFF386641),
        icon: const Icon(Icons.add_alarm, color: Colors.white),
        label: const Text("Novo Alarme", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}