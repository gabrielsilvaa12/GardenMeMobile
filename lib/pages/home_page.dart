import 'package:flutter/material.dart';
import 'package:gardenme/components/add_plant_modal.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/components/plant_card.dart';
import 'package:gardenme/models/planta.dart';
import 'package:gardenme/services/planta_service.dart';
import 'package:gardenme/services/theme_service.dart'; // Importação do ThemeService

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

    // Verifica o tema atual
    final isDark = ThemeService.instance.currentTheme == ThemeOption.escuro;

    // Cores
    const Color lightGreen = Color(0xFFa7c957);
    const Color whiteColor = Color(0xfff2f2f2);

    // LÓGICA SOLICITADA:
    // Tema Claro -> Texto Branco (#f2f2f2)
    // Tema Escuro -> Mantém o Verde Claro (#a7c957)
    final Color textColor = isDark ? lightGreen : whiteColor;

    return InkWell(
      onTap: _abrirModal,
      borderRadius: BorderRadius.circular(50),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xfff2f2f2),
            // O ícone permanece verde claro sempre ("apenas o texto" foi alterado)
            child: const Icon(Icons.add, color: lightGreen),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicionar Planta',
            style: TextStyle(
              color: textColor, // Cor dinâmica aplicada aqui
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
    final isDark = ThemeService.instance.currentTheme == ThemeOption.escuro;
    final titleColor = isDark ? const Color(0xFFa7c957) : const Color(0xFF3A5A40);

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
                        color: titleColor,
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
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                                const Text("Seu jardim está vazio",
                                    style: TextStyle(
                                        color: Color(0xFF3A5A40),
                                        fontSize: 18)),
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
                                    const SizedBox(height: 100),
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
  }
}