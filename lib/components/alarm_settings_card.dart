import 'package:flutter/material.dart';

class AlarmSettingsCard extends StatefulWidget {
  final String plantName;

  const AlarmSettingsCard({super.key, required this.plantName});

  @override
  State<AlarmSettingsCard> createState() => _AlarmSettingsCardState();
}

class _AlarmSettingsCardState extends State<AlarmSettingsCard> {
  bool isRegaActive = true;
  bool isFertilizacaoActive = true;

  Widget _buildAlarmSection({
    required String title,
    required String time,
    required String days,
    required bool isActive,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Color(0xFF344e41),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 3,
                spreadRadius: 1,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      color: Color(0xfff2f2f2),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    days,
                    style: TextStyle(color: Color(0xFFa7c957), fontSize: 16),
                  ),
                ],
              ),
              Switch(
                value: isActive,
                onChanged: onChanged,
                // Cor do 'track' quando ativo (fundo da bolinha)
                activeTrackColor: Color(0xFFa7c957).withOpacity(0.6),
                // Cor da bolinha quando ativa
                activeColor: Color(0xffD9D9D9),
                // Cor do 'track' quando inativo
                inactiveTrackColor: Color(0xFFa1a1a1),
                // Cor da bolinha quando inativa
                inactiveThumbColor: Color(0xffD9D9D9),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF588157),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
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
                  style: TextStyle(color: Color(0xFFa7c957), fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Linha divisória
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(
              color: Color(0xfff2e8cf).withOpacity(0.5),
              height: 2,
              thickness: 2,
            ),
          ),
          SizedBox(height: 12),

          _buildAlarmSection(
            title: 'Rega:',
            time: '11:00',
            days: 'Seg, Qua e Sex',
            isActive: isRegaActive,
            onChanged: (bool value) {
              setState(() {
                isRegaActive = value;
              });
            },
          ),
          SizedBox(height: 20),

          _buildAlarmSection(
            title: 'Fertilização:',
            time: '12:00',
            days: 'Seg, Qua e Sex',
            isActive: isFertilizacaoActive,
            onChanged: (bool value) {
              setState(() {
                isFertilizacaoActive = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
