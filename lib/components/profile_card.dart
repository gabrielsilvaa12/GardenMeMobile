import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gardenme/components/gamification_modal.dart';
import 'package:gardenme/pages/edit_profile_page.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  Future<void> verificarStreak(String uid, int streakAtual) async {
    final userDoc = FirebaseFirestore.instance.collection('usuarios').doc(uid);
    final snap = await userDoc.get();

    if (!snap.exists) return;

    final data = snap.data() as Map<String, dynamic>;
    final String? ultimaRegaStr = data['ultima_rega_data'];

    if (ultimaRegaStr == null) return;

    DateTime ultimaRega = DateTime.parse(ultimaRegaStr);
    DateTime hoje = DateTime.now();

    DateTime hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);
    DateTime ultimaRegaSemHora = DateTime(
      ultimaRega.year,
      ultimaRega.month,
      ultimaRega.day,
    );

    int diferencaDias = hojeSemHora.difference(ultimaRegaSemHora).inDays;

    if (diferencaDias > 1 && streakAtual > 0) {
      await userDoc.update({'streak_atual': 0});
    }
  }

  // --- Lógica dos Subtítulos de Streak ---
  String? _getStreakSubtitle(int streak) {
    if (streak >= 45) return "Que Não Falha";   
    if (streak >= 35) return "Raízes Profundas"; 
    if (streak >= 25) return "Implacável";       
    if (streak >= 15) return "Sempre Verde";     
    if (streak >= 5)  return "Incansável";       
    return null;
  }

  ImageProvider _getAvatarImage(String? fotoPath) {
    if (fotoPath != null && fotoPath.isNotEmpty) {
      try {
        if (fotoPath.startsWith("file://")) {
          return FileImage(File.fromUri(Uri.parse(fotoPath)));
        }
        final file = File(fotoPath);
        if (file.existsSync()) {
          return FileImage(file);
        }
      } catch (e) {
        print("Erro ao ler imagem de perfil: $e");
      }
    }
    return const AssetImage('assets/images/garden.png');
  }

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text(
              "Perfil não encontrado",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        int pontos = userData['pontos'] ?? 0;
        int diasSeguidos = userData['streak_atual'] ?? 0;

        verificarStreak(uid, diasSeguidos);

        // --- Lógica dos Níveis ---
        String nivelNome;
        int minPontos;
        int maxPontos;

        if (pontos < 100) {
          nivelNome = "Regador Iniciante";
          minPontos = 0;
          maxPontos = 100;
        } else if (pontos < 200) {
          nivelNome = "Dedo Verde em Treinamento";
          minPontos = 100;
          maxPontos = 200;
        } else if (pontos < 400) {
          nivelNome = "Encantador(a) de Plantas";
          minPontos = 200;
          maxPontos = 400;
        } else if (pontos < 600) {
          nivelNome = "Mago Verde Certificado";
          minPontos = 400;
          maxPontos = 600;
        } else if (pontos < 800) {
          nivelNome = "Guardião Supremo do Jardim";
          minPontos = 600;
          maxPontos = 800;
        } else {
          nivelNome = "Lenda do Dedo Verde";
          minPontos = 800;
          maxPontos = 800; 
        }

        double progressoVisivel = pontos >= 800
            ? 1.0
            : (pontos - minPontos) / (maxPontos - minPontos);

        progressoVisivel = progressoVisivel.clamp(0.0, 1.0);
        int pontosFaltantes = pontos >= 800 ? 0 : maxPontos - pontos;

        final avatarImage = _getAvatarImage(userData['foto_url']);
        
        String? subtituloStreak = _getStreakSubtitle(diasSeguidos);

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
                clipBehavior: Clip.none, 
                children: [
                  // FOTO DE PERFIL
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFFa7c957).withOpacity(0.5),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundImage: avatarImage,
                    ),
                  ),

                  // ÍCONE DE STREAK (POSIÇÃO AJUSTADA)
                  Positioned(
                    right: -110, 
                    top: -15,    
                    child: Column(
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          color:
                              diasSeguidos > 0 ? Colors.orange : Colors.white24,
                          size: 35,
                        ),
                        // Texto do contador
                        Text(
                          "$diasSeguidos d",
                          style: TextStyle(
                            color: diasSeguidos > 0
                                ? const Color(0xFFFF6D00) 
                                : Colors.white24,
                            fontWeight: FontWeight.w900,
                            fontSize: 16, 
                            shadows: [
                              BoxShadow(
                                color: Colors.orangeAccent.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFa7c957),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // --- TÍTULO DO NÍVEL ---
                        Text(
                          nivelNome,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800, 
                            color: Color(0xff344E41),
                            fontSize: 21, 
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progressoVisivel,
                            backgroundColor: const Color(0xff344E41),
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFF588157),
                            ),
                            minHeight: 12, 
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pontos >= 800 
                            ? 'Nível Máximo Alcançado!'
                            : '$pontosFaltantes Pontos para o próximo nível!',
                          style: const TextStyle(
                            color: Color(0xff344E41),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    Positioned(
                      top: -18,
                      right: -18,
                      child: IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (_) => const GamificationModal(),
                          );
                        },
                        icon: const Icon(
                          Icons.info_outline_rounded,
                          size: 24,
                          color: Color(0xff344E41),
                        ),
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