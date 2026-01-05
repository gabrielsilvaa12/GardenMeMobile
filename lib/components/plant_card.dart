import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _pontosDistribuidos = false;

  Future<void> _atualizarDadosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid);

    String hoje = DateTime.now().toString().split(' ')[0];

    if (statusRega && !_pontosDistribuidos) {
      DocumentSnapshot snap = await userDoc.get();
      var userData = snap.data() as Map<String, dynamic>;
      String? ultimaRega = userData['ultima_rega_data'];

      Map<String, dynamic> updates = {
        'pontos': FieldValue.increment(10),
        'regas_count': FieldValue.increment(1),
      };

      if (ultimaRega != hoje) {
        int atualStreak = (userData['streak_atual'] ?? 0) + 1;
        int melhorStreak = userData['melhor_streak'] ?? 0;

        updates['streak_atual'] = FieldValue.increment(1);
        updates['ultima_rega_data'] = hoje;

        if (atualStreak > melhorStreak) {
          updates['melhor_streak'] = atualStreak;
        }
      }

      await userDoc.update(updates);
      _pontosDistribuidos = true;
    } else if (!statusRega && _pontosDistribuidos) {
      await userDoc.update({
        'pontos': FieldValue.increment(-10),
        'regas_count': FieldValue.increment(-1),
      });
      _pontosDistribuidos = false;
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
                        // Chama a sua lógica de usuário
                        _atualizarDadosUsuario();
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
                      iconColor: const Color(0xfff2f2f2),
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
                      ).withOpacity(0.4),
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
                            builder: (context) => MinhaPlantaPage(
                              nomePlanta: widget.nomePlanta,
                              imagemPlanta: widget.imagemPlanta,
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
