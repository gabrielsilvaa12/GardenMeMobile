import 'package:flutter/material.dart';

class AddAlarmModal extends StatefulWidget {
  final String plantName;

  const AddAlarmModal({super.key, required this.plantName});

  @override
  State<AddAlarmModal> createState() => _AddAlarmModalState();
}

class _AddAlarmModalState extends State<AddAlarmModal> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 13, minute: 0);
  String _selectedAlarmType = 'Rega';
  bool _isVibrateActive = true;

  final _alarmTypes = ['Rega', 'Fertilização'];

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (_, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xff344e41),
            onPrimary: Color(0xfff2e8cf),
            surface: Color(0xfff2e8cf),
            onSurface: Color(0xff344e41),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _addAlarm() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Alarme de $_selectedAlarmType para ${widget.plantName} definido às ${_selectedTime.format(context)}. '
          'Vibração: ${_isVibrateActive ? "Ativa" : "Inativa"}',
        ),
        backgroundColor: const Color(0xff6a994e),
      ),
    );
    Navigator.pop(context);
  }

  Widget _header() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _iconBtn(Icons.close, () => Navigator.pop(context)),
      Text(
        _selectedAlarmType,
        style: const TextStyle(
          color: Color(0xfff2e8cf),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      _iconBtn(Icons.check, _addAlarm),
    ],
  );

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Icon(icon, color: Color(0xfff2f2f2)),
  );

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.75,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: const BoxDecoration(
          color: Color(0xff588157),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(
                color: Color(0xfff2e8cf),
                thickness: 2,
                indent: 120,
                endIndent: 120,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Adicionar alarme',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xfff2f2f2),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),

            // Hora
            GestureDetector(
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: const Color(0xff344e41),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    _selectedTime.format(context),
                    style: const TextStyle(
                      color: Color(0xfff2f2f2),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),
            _optionRow('Repetir', 'Diariamente'),
            const Divider(color: Colors.white24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Vibrar quando o\nalarme disparar',
                  style: TextStyle(color: Color(0xfff2f2f2), fontSize: 16),
                ),
                Switch(
                  value: _isVibrateActive,
                  onChanged: (v) => setState(() => _isVibrateActive = v),
                  activeTrackColor: const Color(0xFFa7c957).withOpacity(0.6),
                  activeColor: const Color(0xffD9D9D9),
                ),
              ],
            ),

            const Divider(color: Colors.white24),
            const SizedBox(height: 30),

            const Text(
              'Tipo de Alarme:',
              style: TextStyle(
                color: Color(0xfff2f2f2),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xff344e41),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _alarmTypes.map((type) {
                  final selected = _selectedAlarmType == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: selected,
                    onSelected: (s) =>
                        setState(() => _selectedAlarmType = type),
                    selectedColor: const Color(0xFFa7c957),
                    backgroundColor: const Color(0xFF588157),
                    labelStyle: TextStyle(
                      color: selected
                          ? const Color(0xff344e41)
                          : const Color(0xfff2f2f2),
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionRow(String title, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(color: Color(0xfff2f2f2), fontSize: 16),
      ),
      Row(
        children: [
          Text(
            value,
            style: const TextStyle(color: Color(0xfff2f2f2), fontSize: 16),
          ),
          const Icon(Icons.chevron_right, color: Color(0xfff2f2f2)),
        ],
      ),
    ],
  );
}
