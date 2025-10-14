import 'package:flutter/material.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/components/plant_card.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return curvedBackground(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: const [
            Text(
              'Meu Jardim',
              style: TextStyle(
                color: Color(0xFF3A5A40),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            PlantCard(
              nomePlanta: 'Morango',
              imagemPlanta: 'assets/images/orango.png',
            ),
            SizedBox(height: 10),
            PlantCard(nomePlanta: 'Babosa', imagemPlanta: 'assets/babosa.png'),
          ],
        ),
      ),
    );
  }
}
