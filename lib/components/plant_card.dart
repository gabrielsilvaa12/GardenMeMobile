import 'package:flutter/material.dart';
import 'package:gardenme/models/planta.dart';
import 'package:gardenme/services/planta_service.dart';
import 'package:gardenme/pages/alarms_page.dart';
import 'package:gardenme/pages/my_plant.dart';

class PlantCard extends StatefulWidget {
  final Planta planta;

  const PlantCard({
    super.key,
    required this.planta,
  });

  @override
  State<PlantCard> createState() => _PlantCardState();
}

class _PlantCardState extends State<PlantCard> {
  final PlantaService _plantaService = PlantaService();

  // Helper para decidir a imagem (URL ou Asset)
  ImageProvider _getImagemPlanta() {
    if (widget.planta.imagemUrl != null && widget.planta.imagemUrl!.isNotEmpty) {
      return NetworkImage(widget.planta.imagemUrl!);
    }

    // Fallback para assets baseado no nome (para plantas padrão)
    switch (widget.planta.nome) {
      case 'Morango':
      case 'Morangueiro':
        return const AssetImage('assets/images/moranguito.png');
      case 'Babosa':
      case 'Aloe Vera':
        return const AssetImage('assets/images/babosada.png');
      case 'Samambaia':
      case 'Fern':
        return const AssetImage('assets/images/samambas.png');
      case 'Jiboia':
      case 'Pothos':
        return const AssetImage('assets/images/jiboia.png');
      default:
        return const AssetImage('assets/images/logoGarden.png'); 
    }
  }

  // Ação de Regar
  void _toggleRega() {
    bool novoStatus = !widget.planta.rega;
    
    _plantaService.atualizarStatus(
      widget.planta.id, 
      rega: novoStatus,
    );
    
    final msg = novoStatus ? 'Planta regada! 💧 (+10 Pontos)' : 'Rega cancelada.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xff386641),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final bool isRegada = widget.planta.rega;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF588157),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Avatar da Planta
          CircleAvatar(
            radius: 45,
            backgroundColor: isRegada
                ? const Color(0xFFAFF695)
                : Colors.orange,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              backgroundImage: _getImagemPlanta(),
            ),
          ),
          const SizedBox(width: 15),
          
          // Informações
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
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                
                // Botões de Ação
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1. Botão Regar
                    _buildActionButton(
                      function: _toggleRega,
                      icon: isRegada ? Icons.water_drop : Icons.water_drop_outlined,
                      backgroundColor: isRegada
                          ? const Color(0xFF81D4FA)
                          : const Color.fromARGB(255, 30, 56, 35).withOpacity(0.4),
                      iconColor: const Color(0xfff2f2f2),
                    ),
                    
                    // 2. Botão Alarme (ATUALIZADO COM plantaId)
                    _buildActionButton(
                      function: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AlarmsPage(
                              plantName: widget.planta.nome,
                              plantaId: widget.planta.id, // Correção aqui!
                            ),
                          ),
                        );
                      },
                      icon: Icons.notifications_none_outlined,
                      backgroundColor: const Color.fromARGB(255, 30, 56, 35).withOpacity(0.4),
                      iconColor: const Color(0xfff2f2f2),
                    ),
                    
                    // 3. Botão Compartilhar (Placeholder)
                    _buildActionButton(
                      function: () {},
                      icon: Icons.share_outlined,
                      backgroundColor: const Color(0xFFE0E0E0),
                      iconColor: Colors.black87,
                    ),
                    
                    // 4. Botão Detalhes
                    _buildActionButton(
                      function: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MinhaPlantaPage(
                              planta: widget.planta,
                            ),
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