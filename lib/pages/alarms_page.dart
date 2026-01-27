import 'package:flutter/material.dart';
import 'package:gardenme/components/add_alarm_modal.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/models/alarme.dart';
import 'package:gardenme/services/alarme_service.dart';

class AlarmsPage extends StatefulWidget {
  final String plantName;
  final String plantaId;

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

  // Helper para formatar os dias da semana
  String _formatarDias(List<int> dias) {
    if (dias.length == 7) return "Todos os dias";
    if (dias.isEmpty) return "Sem repetição";

    const mapaDias = {
      1: 'Seg', 2: 'Ter', 3: 'Qua', 4: 'Qui',
      5: 'Sex', 6: 'Sáb', 7: 'Dom'
    };

    dias.sort();
    return dias.map((d) => mapaDias[d]).join(', ');
  }

  // Lógica para agrupar alarmes pelo Tipo
  Map<String, List<Alarme>> _agruparAlarmesPorTipo(List<Alarme> alarmes) {
    final map = <String, List<Alarme>>{};
    for (var alarme in alarmes) {
      if (!map.containsKey(alarme.tipo)) {
        map[alarme.tipo] = [];
      }
      map[alarme.tipo]!.add(alarme);
    }
    return map;
  }

  // Define a prioridade de exibição: Rega (0) > Fertilização (1) > Outros (2)
  int _getPrioridadeTipo(String tipo) {
    switch (tipo) {
      case 'Rega': return 0;
      case 'Fertilização': return 1;
      default: return 2;
    }
  }

  void _openAddAlarmModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AddAlarmModal(
        plantaId: widget.plantaId,
        nomePlanta: widget.plantName,
      ),
    );
  }

  // Constrói o CARD com Switch e Correção de Estilo
  Widget _buildAlarmCard(Alarme alarme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF344e41),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Horário com correção do erro de cor
              Text(
                alarme.horarioFormatado,
                style: TextStyle(
                  // CORREÇÃO: Aplica opacidade diretamente na cor
                  color: alarme.ativo 
                      ? const Color(0xfff2f2f2) 
                      : const Color(0xfff2f2f2).withOpacity(0.5),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // Dias da semana
              Text(
                _formatarDias(alarme.diasSemana),
                style: TextStyle(
                  color: alarme.ativo 
                      ? const Color(0xFFa7c957) 
                      : const Color(0xFFa7c957).withOpacity(0.5),
                  fontSize: 16
                ),
              ),
            ],
          ),
          
          // TOGGLE (Switch)
          Switch(
            value: alarme.ativo,
            onChanged: (bool valor) {
              _alarmeService.alternarStatus(alarme, valor, widget.plantName);
            },
            // Estilização igual ao design system
            activeColor: const Color(0xffD9D9D9),
            activeTrackColor: const Color(0xFFa7c957).withOpacity(0.6),
            inactiveThumbColor: const Color(0xffD9D9D9),
            inactiveTrackColor: Colors.black26,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFa7c957),
      body: curvedBackground(
        showHeader: true,
        child: StreamBuilder<List<Alarme>>(
          stream: _alarmeService.getAlarmesDaPlanta(widget.plantaId),
          builder: (context, snapshot) {
            final alarmes = snapshot.data ?? [];
            final alarmesAgrupados = _agruparAlarmesPorTipo(alarmes);

            // Ordena as chaves (tipos)
            final tiposOrdenados = alarmesAgrupados.keys.toList()
              ..sort((a, b) => _getPrioridadeTipo(a).compareTo(_getPrioridadeTipo(b)));

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF588157),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabeçalho Interno
                    Row(
                      children: [
                        const Text(
                          'Alarmes: ',
                          style: TextStyle(
                            color: Color(0xfff2e8cf),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.plantName,
                            style: const TextStyle(color: Color(0xFFa7c957), fontSize: 20),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    // Divisória
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(
                        color: const Color(0xfff2e8cf).withOpacity(0.5),
                        height: 2,
                        thickness: 2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Conteúdo
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(child: CircularProgressIndicator(color: Color(0xFFf2f2f2)))
                    else if (alarmes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            "Nenhum alarme configurado.\nToque em + para adicionar.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFFf2f2f2), fontSize: 16),
                          ),
                        ),
                      )
                    else
                      ...tiposOrdenados.map((tipo) {
                        final listaAlarmes = alarmesAgrupados[tipo]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tipo, 
                              style: const TextStyle(
                                color: Color(0xfff2f2f2),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            ...listaAlarmes.map((alarme) => _buildAlarmCard(alarme)),
                            
                            const SizedBox(height: 20),
                          ],
                        );
                      }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddAlarmModal(context),
        backgroundColor: const Color(0xfff2f2f2),
        foregroundColor: const Color(0xff588157),
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}