import 'package:flutter/material.dart';

class AddPlantModal extends StatefulWidget {
  const AddPlantModal({super.key});

  @override
  State<AddPlantModal> createState() => _AddPlantModalState();
}

class _AddPlantModalState extends State<AddPlantModal> {
  String? _selectedPlant;

  final List<String> _plantOptions = [
    'Folha',
    'Aloe Vera',
    'Babosa',
    'Samambaia',
    'Jiboia',
    'Suculenta',
    'Cacto',
    'Lírio da Paz',
    'Costela-de-Adão',
    'Suculentas',
    'Antúrio',
    'Filodendro',
    'Bromélias',
  ];

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Qual planta deseja adicionar?',
              style: TextStyle(
                color: Color(0xfff2f2f2),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            Container(
              width: 60,
              height: 3,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Lista das plantas
            Expanded(
              child: ListView.separated(
                itemCount: _plantOptions.length,
                separatorBuilder: (_, __) => const Divider(
                  color: Colors.white24,
                  thickness: 0.3,
                  indent: 10,
                  endIndent: 10,
                ),
                itemBuilder: (context, index) {
                  final plant = _plantOptions[index];

                  return RadioListTile<String>(
                    title: Text(
                      plant,
                      style: const TextStyle(
                        color: Color(0xfff2f2f2),
                        fontSize: 16,
                      ),
                    ),
                    value: plant,
                    groupValue: _selectedPlant,
                    onChanged: (value) => setState(() {
                      _selectedPlant = value;
                    }),
                    activeColor: const Color(0xff386641),
                    fillColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.selected)) {
                        return const Color(0xff386641);
                      }
                      return const Color(0xfff2f2f2);
                    }),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
