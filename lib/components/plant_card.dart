import 'package:flutter/material.dart';

class PlantCard extends StatelessWidget {
  final String nomePlanta;
  final String imagemPlanta;

  const PlantCard({
    super.key,
    required this.nomePlanta,
    required this.imagemPlanta,
  });

  Widget _buildActionButton({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(right: 8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, size: 22, color: iconColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF689F38),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: const Color(0xFFA5D6A7),
            child: CircleAvatar(
              radius: 32,
              backgroundImage: AssetImage(imagemPlanta),
            ),
          ),
          const SizedBox(width: 15),

          // Coluna para o nome e os ícones
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome da Planta
                Text(
                  nomePlanta,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.water_drop_outlined,
                      backgroundColor: const Color(0xFF81D4FA),
                      iconColor: Colors.white,
                    ),
                    _buildActionButton(
                      icon: Icons.notifications_none_outlined,
                      backgroundColor: const Color(0xFF4E6146),
                      iconColor: Colors.white,
                    ),
                    _buildActionButton(
                      icon: Icons.share_outlined,
                      backgroundColor: const Color(0xFFE0E0E0),
                      iconColor: Colors.black87,
                    ),
                    _buildActionButton(
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
