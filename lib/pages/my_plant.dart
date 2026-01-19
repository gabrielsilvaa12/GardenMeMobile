import 'package:flutter/material.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/components/details_plant.dart';
import 'package:gardenme/components/navbar_card.dart';
import 'package:gardenme/models/planta.dart'; // Importe o Model
import 'package:gardenme/pages/main_page.dart';

class MinhaPlantaPage extends StatefulWidget {
  final Planta planta; // Recebe o objeto completo

  const MinhaPlantaPage({
    super.key,
    required this.planta,
  });

  @override
  State<MinhaPlantaPage> createState() => _MinhaPlantaPageState();
}

class _MinhaPlantaPageState extends State<MinhaPlantaPage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == 1) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage(initialIndex: 1)),
        );
      }
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainPage(initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFa7c957),
      extendBody: true,
      
      bottomNavigationBar: NavbarCard(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
      
      body: curvedBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          children: [
            // Repassa o objeto para o componente de detalhes
            DetailedPlant(planta: widget.planta),
          ],
        ),
      ),
    );
  }
}