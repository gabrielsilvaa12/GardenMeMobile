import 'package:flutter/material.dart';
import 'package:gardenme/pages/alarms_page.dart';
import 'package:gardenme/pages/my_plant.dart';

class PlantCard extends StatefulWidget {
  final String nomePlanta;
  final String imagemPlanta;

  PlantCard({super.key, required this.nomePlanta, required this.imagemPlanta});

  @override
  State<PlantCard> createState() => _PlantCardState();
}

class _PlantCardState extends State<PlantCard> {
  bool statusRega = false;
  bool corPlanta = false;
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
            backgroundColor: corPlanta
                ? const Color(0xFFAFF695)
                : Colors.orange,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(widget.imagemPlanta),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.nomePlanta,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xfff2f2f2),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      function: () {
                        setState(() {
                          statusRega = !statusRega;
                          corPlanta = !corPlanta;
                        });
                      },
                      icon: Icons.water_drop_outlined,
                      backgroundColor: statusRega
                          ? const Color(0xFF81D4FA)
                          : const Color.fromARGB(
                              255,
                              30,
                              56,
                              35,
                            ).withAlpha(102),
                      iconColor: Color(0xfff2f2f2),
                    ),
                    _buildActionButton(
                      function: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AlarmsPage(plantName: widget.nomePlanta),
                          ),
                        );
                      },

                      icon: Icons.notifications_none_outlined,
                      backgroundColor: const Color.fromARGB(
                        255,
                        30,
                        56,
                        35,
                      ).withValues(alpha: 0.4),
                      iconColor: Color(0xfff2f2f2),
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
                            builder: (context) => const MinhaPlantaPage(),
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
