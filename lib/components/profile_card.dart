import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gardenme/pages/edit_profile_page.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        int pontos = userData['pontos'] ?? 0;

        // Lógica de Níveis (0-99, 100-199, etc.)
        String nivelNome;
        int metaNivel;
        if (pontos < 100) {
          nivelNome = "Iniciante";
          metaNivel = 100;
        } else if (pontos < 200) {
          nivelNome = "Cuidador"; // Nome sugerido
          metaNivel = 200;
        } else if (pontos < 300) {
          nivelNome = "Jardineiro";
          metaNivel = 300;
        } else {
          nivelNome = "Mestre Verde";
          metaNivel = pontos + 100; // Caso passe de tudo
        }

        int pontosFaltantes = metaNivel - pontos;
        double progressoVisivel = (pontos % 100) / 100;

        // Lógica do Foguinho (Streak)
        int diasSeguidos = userData['streak_atual'] ?? 0;

        // Lógica da Foto Local
        String? fotoPath = userData['foto_url'];
        ImageProvider avatarImage;
        if (fotoPath != null &&
            fotoPath.isNotEmpty &&
            fotoPath.startsWith('/')) {
          avatarImage = FileImage(File(fotoPath));
        } else {
          avatarImage = const AssetImage('assets/images/garden.png');
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xff588157),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFFa7c957).withOpacity(0.5),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundImage: avatarImage,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Column(
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          color: diasSeguidos > 0
                              ? Colors.orange
                              : Colors.white24,
                          size: 35,
                        ),
                        Text(
                          "$diasSeguidos d",
                          style: TextStyle(
                            color: diasSeguidos > 0
                                ? Colors.orange
                                : Colors.white24,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "${userData['nome']} ${userData['sobrenome'] ?? ''}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xfff2f2f2),
                ),
              ),
              const SizedBox(height: 20),

              // --- SEÇÃO DE PROGRESSO ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFa7c957),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userData['nivel'] ?? 'Iniciante',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff344E41),
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.star,
                          color: Color(0xff344E41),
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progressoVisivel,
                      backgroundColor: const Color(0xff344E41),
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF6A994E),
                      ),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pontosFaltantes > 0
                          ? '$pontosFaltantes pontos para o próximo nível'
                          : 'Nível Máximo atingido!',
                      style: const TextStyle(
                        color: Color(0xff344E41),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    userData['plantas_count']?.toString() ?? "0",
                    "Plantas",
                  ),
                  _buildDivider(),
                  _buildStatItem(pontos.toString(), "Pontos"),
                  _buildDivider(),
                  _buildStatItem(
                    userData['regas_count']?.toString() ?? "0",
                    "Regas",
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFA7C957),
                      child: Icon(
                        Icons.emoji_events_rounded,
                        color: Color(0xff344E41),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Recorde Pessoal",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Melhor sequência: ${userData['melhor_streak'] ?? 0} dias",
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfilePage(userData: userData),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA7C957),
                  foregroundColor: const Color(0xFF3A5A40),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Editar Perfil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xffF2E8CF),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xfff2f2f2)),
        ),
      ],
    );
  }

  Widget _buildDivider() =>
      Container(height: 30, width: 1, color: Colors.white24);
}
