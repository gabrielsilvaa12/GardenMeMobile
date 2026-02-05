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
      body: Stack(
        children: [
          curvedBackground(
            child: ListView(
              // AJUSTE: Padding bottom 150 para subir a data final
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 150),
              children: [
                DetailedPlant(planta: planta),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}