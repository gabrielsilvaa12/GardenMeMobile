import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gardenme/pages/edit_profile_page.dart';
import 'package:gardenme/pages/login.dart';

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
        double progressoVisivel = (pontos % 100) / 100;

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
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFFa7c957).withOpacity(0.5),
                child: CircleAvatar(radius: 56, backgroundImage: avatarImage),
              ),
              const SizedBox(height: 16),
              Text(
                "${userData['nome']} ${userData['sobrenome'] ?? ''}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xf2f2f2f2),
                ),
              ),
              const SizedBox(height: 20),

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
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Meu progresso',
                      style: TextStyle(color: Color(0xfff2f2f2), fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem("0", "Plantas"),
                  _buildDivider(),
                  _buildStatItem(pontos.toString(), "Pontos"),
                  _buildDivider(),
                  _buildStatItem("0", "Regas"),
                ],
              ),

              const SizedBox(height: 25),

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
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Editar Perfil',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              TextButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MyLogin()),
                    (r) => false,
                  );
                },
                icon: const Icon(
                  Icons.logout,
                  color: Colors.redAccent,
                  size: 18,
                ),
                label: const Text(
                  "Sair da conta",
                  style: TextStyle(color: Colors.redAccent),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xffF2E8CF),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xfff2f2f2)),
        ),
      ],
    );
  }

  Widget _buildDivider() =>
      Container(height: 25, width: 1, color: Colors.white24);
}
