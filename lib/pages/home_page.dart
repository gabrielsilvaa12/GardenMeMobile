import 'package:flutter/material.dart';
import 'package:gardenme/components/add_plant_modal.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/components/plant_card.dart';
import 'package:gardenme/models/planta.dart';
import 'package:gardenme/services/planta_service.dart';
import 'package:gardenme/services/theme_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PlantaService _plantaService = PlantaService();

  @override
  void initState() {
    super.initState();
    _plantaService.verificarAlarmesVencidos();
  }

  Widget _buildAddPlantButton(BuildContext context) {
    void _abrirModal() {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => const AddPlantModal(),
      );
    }

    // Verifica o tema atual para definir a cor do ícone
    final isDark = ThemeService.instance.currentTheme == ThemeOption.escuro;

    // Cores
    const Color lightGreen = Color(0xFFa7c957);
    const Color darkGreen = Color(0xFF3A5A40);
    
    // Cor fixa branca para o texto
    const Color fixedWhiteColor = Color(0xfff2f2f2);

    // Lógica do ícone: Verde Claro no tema Claro / Verde Escuro no tema Escuro
    final Color iconColor = isDark ? darkGreen : lightGreen;

    return InkWell(
      onTap: _abrirModal,
      borderRadius: BorderRadius.circular(50),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xfff2f2f2),
            child: Icon(Icons.add, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicionar Planta',
            style: TextStyle(
              color: fixedWhiteColor,
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
    return AnimatedBuilder(
      animation: ThemeService.instance,
      builder: (context, child) {
        final isDark = ThemeService.instance.currentTheme == ThemeOption.escuro;
        
        // Lógica de Cor para Títulos e Textos de destaque:
        // Tema Claro -> Verde Escuro (0xFF3A5A40)
        // Tema Escuro -> Verde Claro (0xFFa7c957)
        final dynamicTextColor = isDark ? const Color(0xFFa7c957) : const Color(0xFF3A5A40);

        return Scaffold(
          extendBody: true,
          backgroundColor: const Color(0xFFa7c957),
          body: Column(
            children: [
              Expanded(
                child: curvedBackground(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'Meu Jardim',
                          style: TextStyle(
                            color: dynamicTextColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: StreamBuilder<List<Planta>>(
                            stream: _plantaService.getMinhasPlantas(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF3A5A40),
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return const Center(
                                    child: Text('Erro ao carregar jardim.'));
                              }

                              final plantas = snapshot.data ?? [];

                              if (plantas.isEmpty) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Seu jardim está vazio",
                                      style: TextStyle(
                                          color: dynamicTextColor,
                                          fontSize: 18),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildAddPlantButton(context),
                                  ],
                                );
                              }

                              return ListView.builder(
                                itemCount: plantas.length + 1,
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) {
                                  if (index == plantas.length) {
                                    return Column(
                                      children: [
                                        const SizedBox(height: 20),
                                        _buildAddPlantButton(context),
                                        // AUMENTADO DE 100 PARA 180 PARA EVITAR QUE A NAVBAR CUBRA O BOTÃO
                                        const SizedBox(height: 180),
                                      ],
                                    );
                                  }

                                  final planta = plantas[index];
                                  return PlantCard(planta: planta);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}