import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gardenme/models/planta.dart';
import 'package:gardenme/pages/alarms_page.dart';
import 'package:gardenme/services/planta_service.dart';

class DetailedPlant extends StatefulWidget {
  final Planta planta;

  const DetailedPlant({super.key, required this.planta});

  @override
  State<DetailedPlant> createState() => _DetailedPlantState();
}

class _DetailedPlantState extends State<DetailedPlant> {
  final PlantaService _plantaService = PlantaService();

  Widget _buildPlantImage() {
    final imagePath = widget.planta.imagemUrl ?? '';
    
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else if (imagePath.isNotEmpty) {
      return Image.file(
        File(imagePath),
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 250,
      color: Colors.white24,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 50, color: Colors.white54),
      ),
    );
  }

  Widget _buildInfoSection(String titulo, String conteudo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Color(0xFFa7c957),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            conteudo,
            style: const TextStyle(
              color: Color(0xfff2f2f2),
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _irParaAlarmes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmsPage(
          plantName: widget.planta.nome,
          plantaId: widget.planta.id,
        ),
      ),
    );
  }

  Future<void> _excluirPlanta() async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir planta?"),
        content: const Text("Isso apagará a planta e seus alarmes permanentemente."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Excluir", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await _plantaService.removerPlanta(widget.planta);
      if (mounted) Navigator.pop(context); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final estacao = widget.planta.estacaoIdeal ?? 'Ano todo';
    final umidade = widget.planta.regaDica ?? 'Verifique a umidade do solo regularmente.';
    final terra = widget.planta.tipoTerra ?? 'Terra vegetal preta rica em matéria orgânica.';
    final fertilizante = widget.planta.dicaFertilizante ?? 'Adubo orgânico ou NPK 10-10-10.';

    return Column(
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF588157),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- STACK: FOTO + BOTÃO ALARME (Topo Direito) ---
              Stack(
                children: [
                  _buildPlantImage(),
                  
                  // Botão Redondo de Alarmes (Overlay - Canto Superior Direito)
                  Positioned(
                    top: 16, // Movido para o topo
                    right: 16,
                    child: InkWell(
                      onTap: _irParaAlarmes,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 50, // Levemente reduzido (era 56)
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xfff2f2f2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.alarm, 
                          color: Color(0xFF588157),
                          size: 24, // Levemente reduzido (era 28)
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TÍTULO CENTRALIZADO
                    Center(
                      child: Text(
                        widget.planta.nome,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xfff2f2f2),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Card da Estação
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF344e41),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFa7c957).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, color: Color(0xFFa7c957)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Melhor época para plantar:",
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                Text(
                                  estacao,
                                  style: const TextStyle(
                                    color: Color(0xfff2f2f2),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Informações
                    _buildInfoSection("Umidade da terra:", umidade),
                    _buildInfoSection("Qual terra usar:", terra),
                    _buildInfoSection("Fertilizante ideal:", fertilizante),

                    const SizedBox(height: 30),

                    // BOTÃO EXCLUIR (Cor e Tamanho ajustados)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _excluirPlanta,
                        icon: const Icon(Icons.delete_outline, size: 26),
                        label: const Text(
                          "Excluir Planta",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFbc4749), // Nova cor solicitada
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12), // Padding reduzido de 16 para 12
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 4,
                          shadowColor: const Color(0xFFbc4749).withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}