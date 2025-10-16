import 'package:flutter/material.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/components/header.dart';
import 'package:gardenme/components/plant_card.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFa7c957),
      body: Column(
        children: [
          const Header(),
          Expanded(
            child: curvedBackground(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  children: [
                    const Text(
                      'Meu Jardim',
                      style: TextStyle(
                        color: Color(0xFF3A5A40),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    PlantCard(
                      nomePlanta: 'Morango',
                      imagemPlanta: 'assets/images/moranguito.png',
                    ),
                    const SizedBox(height: 10),
                    PlantCard(
                      nomePlanta: 'Babosa',
                      imagemPlanta: 'assets/images/babosada.png',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
