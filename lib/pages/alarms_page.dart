import 'package:flutter/material.dart';
import 'package:gardenme/components/add_alarm_modal.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/models/alarme.dart';
import 'package:gardenme/services/alarme_service.dart';
import 'package:gardenme/services/notification_service.dart';

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

  String _formatarDias(List<int> dias) {
    if (dias.length == 7) return "Todos os dias";
    if (dias.isEmpty) return "Sem repetição";

    const mapaDias = {
      1: 'Seg',
      2: 'Ter',
      3: 'Qua',
      4: 'Qui',
      5: 'Sex',
      6: 'Sáb',
      7: 'Dom'
    };

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
      backgroundColor: const Color(0xFFa7c957),
      body: curvedBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: StreamBuilder<List<Alarme>>(
            stream: _alarmeService.getAlarmesDaPlanta(widget.plantaId),
            builder: (context, snapshot) {
              final alarmes = snapshot.data ?? [];

              return ListView(
                padding: const EdgeInsets.only(bottom: 140),
                children: [
                  const SizedBox(height: 30),
                  Text(
                    'Alarmes: ${widget.plantName}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3A5A40),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ...alarmes.map((alarme) => Card(
                        child: ListTile(
                          title: Text(alarme.horarioFormatado),
                          subtitle: Text(
                            '${alarme.tipo} • ${_formatarDias(alarme.diasSemana)}',
                          ),
                        ),
                      )),
                ],
              );
            },
          ),
        ),
      ),

      /// 🔘 BOTÕES FLUTUANTES
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'teste_notificacao',
            backgroundColor: Colors.orange,
            icon: const Icon(Icons.notification_important),
            label: const Text('Testar Notificação'),
            onPressed: () async {
              await NotificationService().notificarTesteEm8Segundos();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notificação de teste em 8 segundos ⏱️'),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'novo_alarme',
            backgroundColor: const Color(0xFF386641),
            icon: const Icon(Icons.add_alarm),
            label: const Text('Novo Alarme'),
            onPressed: () => _abrirModalAdicionar(context),
          ),
        ],
      ),
    );
  }
}