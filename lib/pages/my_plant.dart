import 'package:flutter/material.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/components/details_plant.dart';
import 'package:gardenme/components/navbar_card.dart'; // 1. Importe o NavbarCard

class MinhaPlantaPage extends StatelessWidget {
  const MinhaPlantaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFa7c957),

      body: curvedBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          children: const [DetailedPlant()],
        ),
      ),

      bottomNavigationBar: const NavbarCard(selectedIndex: 1),
    );
  }
}
