import 'package:flutter/material.dart';
import 'package:gardenme/components/add_plant_modal.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/components/plant_card.dart';
import 'package:gardenme/models/planta.dart';
import 'package:gardenme/services/planta_service.dart';

// ALTERAÇÃO 1: Mudamos para StatefulWidget para poder iniciar a verificação de alarmes
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Instância do serviço
  final PlantaService _plantaService = PlantaService();

  @override
  void initState() {
    super.initState();
    // LÓGICA VITAL: Verifica se algum alarme venceu ao abrir a Home.
    // Se venceu, a planta fica com status 'false' (Laranja) e permite regar novamente para ganhar pontos.
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
                child: Column(
                  children: [
                    const SizedBox(height: 20),
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
                    
                    // Listagem Dinâmica com StreamBuilder
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
                            return const Center(child: Text('Erro ao carregar jardim.'));
                          }

                          // Lista de plantas do banco (ou vazia)
                          final plantas = snapshot.data ?? [];

                          if (plantas.isEmpty) {
                             return Column(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 const Text("Seu jardim está vazio 🌱", style: TextStyle(color: Color(0xFF3A5A40), fontSize: 18)),
                                 const SizedBox(height: 20),
                                 _buildAddPlantButton(context),
                               ],
                             );
                          }

                          return ListView.builder(
                            itemCount: plantas.length + 1, // +1 para o botão adicionar no final
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              // Se for o último item, renderiza o botão
                              if (index == plantas.length) {
                                return Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    _buildAddPlantButton(context),
                                    const SizedBox(height: 100), // Espaço extra para o menu inferior
                                  ],
                                );
                              }

                              final planta = plantas[index];
                              // Este Card já contém a lógica de clique -> Atualizar Pontos
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