import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gardenme/models/planta.dart';
import 'package:gardenme/pages/alarms_page.dart';
import 'package:gardenme/pages/my_plant.dart';
import 'package:gardenme/services/planta_service.dart';

class PlantCard extends StatefulWidget {
  final Planta planta;

  const PlantCard({super.key, required this.planta});

  @override
  State<PlantCard> createState() => _PlantCardState();
}

class _PlantCardState extends State<PlantCard> {
  final PlantaService _plantaService = PlantaService();

  // Função para regar (Conectada ao Serviço que conta pontos)
  Future<void> _toggleRega() async {
    bool novoStatus = !widget.planta.rega;
    
    // Chama o serviço que já tem a lógica de +10 pontos e streak
    await _plantaService.atualizarStatus(
      widget.planta.id, 
      rega: novoStatus,
    );
    
    // O StreamBuilder na Home vai atualizar a tela automaticamente
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback function,
  }) {
    return InkWell(
      onTap: function,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(right: 8.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: iconColor),
      ),
    );
  }

  ImageProvider _getImagemProvider() {
    final path = widget.planta.imagemUrl;
    if (path != null && path.isNotEmpty) {
      try {
        if (path.startsWith('http')) return NetworkImage(path);
        return FileImage(File(path));
      } catch (_) {}
    }
    return const AssetImage('assets/images/garden.png');
  }

  @override
  Widget build(BuildContext context) {
    bool statusRega = widget.planta.rega;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF588157),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: statusRega
                ? const Color(0xFFAFF695) // Verde (Regada)
                : Colors.orange,      // Laranja (Precisa Regar)
            child: CircleAvatar(
              radius: 40,
              backgroundImage: _getImagemProvider(),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.planta.nome,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xfff2f2f2),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botão Rega
                    _buildActionButton(
                      function: _toggleRega,
                      icon: Icons.water_drop_outlined,
                      backgroundColor: statusRega
                          ? const Color(0xFF81D4FA)
                          : const Color.fromARGB(255, 30, 56, 35).withAlpha(102),
                      iconColor: const Color(0xfff2f2f2),
                    ),
                    // Botão Alarmes
                    _buildActionButton(
                      function: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AlarmsPage(
                              plantName: widget.planta.nome,
                              plantaId: widget.planta.id,
                            ),
                          ),
                        );
                      },
                      icon: Icons.notifications_none_outlined,
                      backgroundColor: const Color.fromARGB(255, 30, 56, 35).withOpacity(0.4),
                      iconColor: const Color(0xfff2f2f2),
                    ),
                    // Botão Compartilhar
                    _buildActionButton(
                      function: () {},
                      icon: Icons.share_outlined,
                      backgroundColor: const Color(0xFFE0E0E0),
                      iconColor: Colors.black87,
                    ),
                    // Botão Detalhes
                    _buildActionButton(
                      function: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MinhaPlantaPage(planta: widget.planta),
                          ),
                        );
                      },
                      icon: Icons.add,
                      backgroundColor: const Color(0xFFE0E0E0),
                      iconColor: Colors.black87,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}