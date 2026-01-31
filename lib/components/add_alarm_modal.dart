import 'package:flutter/material.dart';
import 'package:gardenme/models/alarme.dart';
import 'package:gardenme/services/alarme_service.dart';
import 'package:gardenme/services/notification_service.dart';

class AddAlarmModal extends StatefulWidget {
  final String plantaId;
  final String nomePlanta;
  final Alarme? alarmeParaEditar;

  const AddAlarmModal({
    super.key,
    required this.plantaId,
    required this.nomePlanta,
    this.alarmeParaEditar,
  });

  @override
  State<AddAlarmModal> createState() => _AddAlarmModalState();
}

class _AddAlarmModalState extends State<AddAlarmModal> {
  final AlarmeService _alarmeService = AlarmeService();

  late TimeOfDay _selectedTime;
  late String _tipoSelecionado;
  late List<int> _diasSelecionados;

  // REMOVIDO "Poda" da lista
  final List<String> _tipos = ['Rega', 'Fertilização'];

  final Map<int, String> _diasMap = {
    1: 'S',
    2: 'T',
    3: 'Q',
    4: 'Q',
    5: 'S',
    6: 'S',
    7: 'D'
  };

  @override
  void initState() {
    super.initState();
    _pedirPermissao();

    if (widget.alarmeParaEditar != null) {
      final a = widget.alarmeParaEditar!;
      _selectedTime = TimeOfDay(hour: a.hora, minute: a.minuto);

      // Se estiver editando um alarme antigo que por acaso seja "Poda",
      // ele manterá o tipo original até o usuário mudar, ou mudará para Rega se preferir forçar.
      // Aqui mantemos o original para evitar erros visuais, mas a opção de selecionar "Poda" sumiu.
      _tipoSelecionado = a.tipo;

      _diasSelecionados = List.from(a.diasSemana);
    } else {
      _selectedTime = TimeOfDay.now();
      _tipoSelecionado = 'Rega';
      _diasSelecionados = [1, 2, 3, 4, 5, 6, 7];
    }
  }

  Future<void> _pedirPermissao() async {
    await NotificationService().requestPermissions();
  }

  Future<void> _pickTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            useMaterial3: true,
            colorScheme: const ColorScheme.light(
              primary:
                  Color(0xFFa7c957), // 🌱 Cor principal (Ponteiro e Seleção)
              onPrimary:
                  Color(0xFFf2f2f2), // Cor do texto sobre o verde principal
              surface: Color(0xFFf2f2f2), // Fundo do modal
              onSurface: Color(0xFFf2f2f2), // Texto comum e números do relógio
            ),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Color(0xFF588157), // Fundo do modal
              hourMinuteColor:
                  Color(0xFF344e41), // Fundo dos retângulos de hora/minuto
              hourMinuteTextColor: Color(0xFFf2f2f2), // Texto da hora/minuto
              dialBackgroundColor:
                  Color(0xFF588157), // Fundo do círculo do relógio
              dialHandColor: Color(0xFFa7c957), // Cor do ponteiro
              dialTextColor: Color(0xFFf2f2f2), // Cor dos números no círculo
              entryModeIconColor: Color(0xFFa7c957), // Ícone de teclado
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _toggleDia(int dia) {
    setState(() {
      if (_diasSelecionados.contains(dia)) {
        _diasSelecionados.remove(dia);
      } else {
        _diasSelecionados.add(dia);
      }
    });
  }

  Future<void> _salvar() async {
    if (_diasSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione pelo menos um dia da semana!")),
      );
      return;
    }

    try {
      if (widget.alarmeParaEditar != null) {
        await _alarmeService.editarAlarme(
          alarmeAntigo: widget.alarmeParaEditar!,
          nomePlanta: widget.nomePlanta,
          novoTipo: _tipoSelecionado,
          novaHora: _selectedTime.hour,
          novoMinuto: _selectedTime.minute,
          novosDias: _diasSelecionados,
        );
      } else {
        await _alarmeService.criarAlarme(
          plantaId: widget.plantaId,
          nomePlanta: widget.nomePlanta,
          tipo: _tipoSelecionado,
          hora: _selectedTime.hour,
          minuto: _selectedTime.minute,
          diasSemana: _diasSelecionados,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.alarmeParaEditar != null
                  ? "Alarme atualizado! 🔄"
                  : "Alarme salvo! ⏰"),
              backgroundColor: const Color(0xFF386641)),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Erro"),
            content: Text("Não foi possível salvar:\n$e"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
            ],
          ),
        );
      }
    }
  }

  Future<void> _excluir() async {
    try {
      if (widget.alarmeParaEditar != null) {
        await _alarmeService.deletarAlarme(widget.alarmeParaEditar!);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Alarme excluído! 🗑️"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao excluir: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.alarmeParaEditar != null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF588157),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),

          // CABEÇALHO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? "Editar Alarme" : "Novo Alarme",
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xfff2f2f2)),
              ),
              if (isEditing)
                InkWell(
                  onTap: _excluir,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.white, size: 24),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Chips de Tipo (Agora sem Poda)
          Row(
            children: _tipos.map((tipo) {
              final isSelected = _tipoSelecionado == tipo;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(tipo),
                  selected: isSelected,
                  selectedColor: const Color(0xFFA7C957),
                  labelStyle: TextStyle(
                      color:
                          isSelected ? const Color(0xFF344e41) : Colors.black54,
                      fontWeight: FontWeight.bold),
                  onSelected: (bool selected) {
                    if (selected) setState(() => _tipoSelecionado = tipo);
                  },
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Seletor de Hora
          InkWell(
            onTap: _pickTime,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: Color(0xFF344e41),
                borderRadius: BorderRadius.circular(15),
                // border: Border.all(color: const Color(0xFFA7C957)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Horário",
                      style: TextStyle(fontSize: 16, color: Color(0xfff2f2f2))),
                  Text(
                    "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xfff2f2f2)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Seletor de Dias
          const Text("Repetir nos dias:",
              style: TextStyle(
                  fontSize: 16,
                  color: Color(0xfff2f2f2),
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _diasMap.entries.map((entry) {
              final dia = entry.key;
              final letra = entry.value;
              final isSelected = _diasSelecionados.contains(dia);

              return GestureDetector(
                onTap: () => _toggleDia(dia),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFFA7C957) : Colors.white,
                    border: Border.all(
                        color: isSelected
                            ? const Color(0xFFA7C957)
                            : Color(0xFF344e41)),
                  ),
                  child: Text(
                    letra,
                    style: TextStyle(
                      color: isSelected ? Color(0xFF344e41) : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 30),

          // Botão Salvar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF344e41),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
              ),
              child: Text(
                isEditing ? "SALVAR ALTERAÇÕES" : "DEFINIR ALARME",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xfff2f2f2)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
