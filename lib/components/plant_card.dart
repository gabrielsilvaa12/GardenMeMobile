import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gardenme/models/planta.dart';
import 'package:gardenme/pages/alarms_page.dart';
import 'package:gardenme/pages/my_plant.dart';
import 'package:gardenme/services/planta_service.dart';
import 'package:gardenme/services/theme_service.dart';

class PlantCard extends StatefulWidget {
  final Planta planta;

  const PlantCard({super.key, required this.planta});

  @override
  State<PlantCard> createState() => _PlantCardState();
}

class _PlantCardState extends State<PlantCard> {
  final PlantaService _plantaService = PlantaService();

  Future<void> _toggleRega() async {
    if (widget.planta.rega) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Você já cuidou desta planta hoje! 🌱',
            style: TextStyle(color: Color(0xFF344e41), fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFFA7C957), // Verde Claro
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await _plantaService.atualizarStatus(
      widget.planta.id, 
      rega: true,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Planta regada com amor! 💧 +10 XP',
            style: TextStyle(color: Color(0xFF344e41), fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFFA7C957), // Verde Claro
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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

    final isDark = ThemeService.instance.currentTheme == ThemeOption.escuro;
    final cardColor = isDark ? const Color(0xFF588157) : const Color(0xFF588157);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: statusRega
                ? const Color(0xFFAFF695)
                : Colors.orange,
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
                    _buildActionButton(
                      function: _toggleRega,
                      icon: Icons.water_drop_outlined,
                      backgroundColor: statusRega
                          ? const Color(0xFF81D4FA)
                          : const Color.fromARGB(255, 30, 56, 35).withAlpha(102),
                      iconColor: const Color(0xfff2f2f2),
                    ),
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
                    _buildActionButton(
                      function: () {},
                      icon: Icons.share_outlined,
                      backgroundColor: const Color(0xFFE0E0E0),
                      iconColor: Colors.black87,
                    ),
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