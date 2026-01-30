import 'package:flutter/material.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/components/details_plant.dart';
import 'package:gardenme/models/planta.dart';

class MinhaPlantaPage extends StatelessWidget {
  final Planta planta;

  const MinhaPlantaPage({
    super.key,
    required this.planta,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFa7c957),
      body: curvedBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          children: [
            DetailedPlant(planta: planta),
          ],
        ),
      ),
    );
  }
}