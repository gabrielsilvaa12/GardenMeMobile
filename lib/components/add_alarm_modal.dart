import 'package:flutter/material.dart';
import 'package:gardenme/services/alarme_service.dart';
import 'package:gardenme/services/notification_service.dart'; // Importe para pedir permissão

class AddAlarmModal extends StatefulWidget {
  final String plantaId;
  final String nomePlanta;

  const AddAlarmModal({
    super.key,
    required this.plantaId,
    required this.nomePlanta,
  });

  @override
  State<AddAlarmModal> createState() => _AddAlarmModalState();
}

class _AddAlarmModalState extends State<AddAlarmModal> {
  final AlarmeService _alarmeService = AlarmeService();
  
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _tipoSelecionado = 'Rega';
  
  // Começa com TODOS os dias selecionados por padrão (UX melhor)
  final List<int> _diasSelecionados = [1, 2, 3, 4, 5, 6, 7];

  final List<String> _tipos = ['Rega', 'Fertilização', 'Poda'];
  
  final Map<int, String> _diasMap = {
    1: 'S', 2: 'T', 3: 'Q', 4: 'Q', 5: 'S', 6: 'S', 7: 'D'
  };

  @override
  void initState() {
    super.initState();
    // Ao abrir o modal, garante que temos permissão
    _pedirPermissao();
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
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF386641),
              onPrimary: Colors.white,
              onSurface: Color(0xFF386641),
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

  Future<void> _salvarAlarme() async {
    if (_diasSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione pelo menos um dia da semana!")),
      );
      return;
    }

    try {
      // Chama o serviço
      await _alarmeService.criarAlarme(
        plantaId: widget.plantaId,
        nomePlanta: widget.nomePlanta,
        tipo: _tipoSelecionado,
        hora: _selectedTime.hour,
        minuto: _selectedTime.minute,
        diasSemana: _diasSelecionados,
      );

      // Se chegou aqui, deu certo (ou erro de notificação foi tratado no service)
      if (mounted) {
        Navigator.pop(context); // FECHA O MODAL
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Alarme salvo com sucesso! ⏰"), 
            backgroundColor: Color(0xFF386641)
          ),
        );
      }
    } catch (e) {
      // Se der erro CRÍTICO (ex: usuário deslogado, erro de rede no Firestore)
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Erro"),
            content: Text("Não foi possível salvar o alarme:\n$e"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50, height: 5,
              decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
          
          const Text(
            "Novo Alarme",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF386641)),
          ),
          
          const SizedBox(height: 20),
          
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
                    color: isSelected ? const Color(0xFF386641) : Colors.black54,
                    fontWeight: FontWeight.bold
                  ),
                  onSelected: (bool selected) {
                    if (selected) setState(() => _tipoSelecionado = tipo);
                  },
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          InkWell(
            onTap: _pickTime,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFA7C957)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Horário", style: TextStyle(fontSize: 16, color: Colors.black54)),
                  Text(
                    "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF386641)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text("Repetir nos dias:", style: TextStyle(fontSize: 16, color: Colors.black87)),
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
                  width: 40, height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFF386641) : Colors.white,
                    border: Border.all(color: isSelected ? const Color(0xFF386641) : Colors.grey[400]!),
                  ),
                  child: Text(
                    letra,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _salvarAlarme,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF386641),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              child: const Text(
                "DEFINIR ALARME",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}