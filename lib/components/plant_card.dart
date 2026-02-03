import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gardenme/models/planta.dart';
import 'package:gardenme/pages/alarms_page.dart';
import 'package:gardenme/pages/my_plant.dart';
import 'package:gardenme/services/planta_service.dart';
import 'package:gardenme/services/theme_service.dart';

// Imports para o compartilhamento
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gardenme/components/plant_share_card.dart';

class PlantCard extends StatefulWidget {
  final Planta planta;

  const PlantCard({super.key, required this.planta});

  @override
  State<PlantCard> createState() => _PlantCardState();
}

class _PlantCardState extends State<PlantCard> {
  final PlantaService _plantaService = PlantaService();
  
  // Controlador para capturar a imagem
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _toggleRega() async {
    if (widget.planta.rega) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Você já cuidou desta planta hoje! 🌱',
            style: TextStyle(color: Color(0xFF344e41), fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.white,
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
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Função para buscar dados do usuário e compartilhar
  Future<void> _compartilharPlanta() async {
    // 1. Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator(color: Colors.white));
      },
    );

    try {
      // 2. Buscar dados do usuário no Firebase
      final user = FirebaseAuth.instance.currentUser;
      String nomeUsuario = "Jardineiro";
      String nivelUsuario = "Iniciante";

      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          final data = doc.data()!;
          nomeUsuario = data['nome'] ?? "Jardineiro";
          nivelUsuario = data['nivel'] ?? "Iniciante";
        }
      }

      // Fecha o loading inicial (circular progress)
      if (mounted) Navigator.pop(context);

      // 3. Montar o Widget de Compartilhamento (Invisível para o usuário, mas visível para o Screenshot)
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Screenshot(
                  controller: _screenshotController,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    // AQUI ESTÁ A CORREÇÃO: Passando os dados do usuário
                    child: PlantShareCard(
                      planta: widget.planta,
                      nomeUsuario: nomeUsuario,
                      nivelUsuario: nivelUsuario,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Gerando imagem...",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                )
              ],
            ),
          );
        },
      );

      // Pequeno delay para renderização do widget
      await Future.delayed(const Duration(milliseconds: 500));

      // 4. Capturar e Compartilhar
      final imageBytes = await _screenshotController.capture();

      if (mounted) Navigator.pop(context); // Fecha o dialog de geração

      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/gardenme_share.png').create();
        await imagePath.writeAsBytes(imageBytes);

        await Share.shareXFiles(
          [XFile(imagePath.path)],
          text: 'Veja minha ${widget.planta.nome} no GardenMe! 🌿',
        );
      }

    } catch (e) {
      // Garante que fecha qualquer dialog aberto se der erro
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao compartilhar: $e")),
        );
      }
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
                    // BOTÃO COMPARTILHAR
                    _buildActionButton(
                      function: _compartilharPlanta,
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