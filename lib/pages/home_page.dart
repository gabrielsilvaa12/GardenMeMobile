import 'package:flutter/material.dart';
import 'package:gardenme/components/add_plant_modal.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/components/plant_card.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  Widget _buildAddPlantButton(BuildContext context) {
    void _abrirModal() {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => const AddPlantModal(),
      );
    }

    return InkWell(
      onTap: _abrirModal,
      borderRadius: BorderRadius.circular(50),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xfff2f2f2),
            child: const Icon(Icons.add, color: Color(0xff386641)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adicionar Planta',
            style: TextStyle(
              color: Color(0xff386641),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFa7c957),
      body: Column(
        children: [
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
                    const SizedBox(height: 10),
                    PlantCard(
                      nomePlanta: 'Samambaia',
                      imagemPlanta: 'assets/images/samambas.png',
                    ),
                    const SizedBox(height: 10),
                    PlantCard(
                      nomePlanta: 'Jiboia',
                      imagemPlanta: 'assets/images/jiboia.png',
                    ),
                    const SizedBox(height: 20),
                    _buildAddPlantButton(context),
                    const SizedBox(height: 100),
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
