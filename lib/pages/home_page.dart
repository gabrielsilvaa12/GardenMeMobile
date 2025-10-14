import 'package:flutter/material.dart';
import 'package:gardenme/components/header.dart';
import 'package:gardenme/components/plant_card.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(14)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E7D32), Color(0xFF81C784)],
          ),
        ),
        child: Column(
          children: [
            const Header(),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(color: Colors.white),
                child: ListView(
                  children: const [
                    SizedBox(height: 20),
                    Text(
                      'Meu Jardim',
                      style: TextStyle(
                        color: const Color(0xFF3A5A40),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    PlantCard(
                      nomePlanta: 'Morango',
                      imagemPlanta: 'assets/images/orango.png',
                    ),
                    SizedBox(height: 10),
                    PlantCard(
                      nomePlanta: 'Babosa',
                      imagemPlanta: 'assets/babosa.png', // Adicione esta imagem
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
