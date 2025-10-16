import 'package:flutter/material.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/components/details_plant.dart';

class MinhaPlantaPage extends StatelessWidget {
  const MinhaPlantaPage({super.key});

  @override
  Widget build(BuildContext context) {
    // A página também volta a ser apenas o curvedBackground
    return curvedBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        children: const [DetailsPlantCard()],
      ),
    );
  }
}
