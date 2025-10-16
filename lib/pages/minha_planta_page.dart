import 'package:flutter/material.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/components/detailed_plant.dart';

class MinhaPlantaPage extends StatelessWidget {
  const MinhaPlantaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return curvedBackground(
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: const [DetailedPlant()],
      ),
    );
  }
}
