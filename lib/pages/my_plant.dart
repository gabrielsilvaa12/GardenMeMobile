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
      // Fundo verde suave conforme o design system
      backgroundColor: const Color(0xFFa7c957),
      
      // Background curvo padrão (mantém a identidade visual)
      body: curvedBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          children: [
            // Passamos o objeto completo para garantir que Edição/Exclusão funcionem
            DetailedPlant(planta: planta),
            
            // Espaço extra no final para evitar que o conteúdo fique colado na borda
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}