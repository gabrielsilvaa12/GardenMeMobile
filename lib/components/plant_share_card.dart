import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gardenme/models/planta.dart';

class PlantShareCard extends StatelessWidget {
  final Planta planta;
  final String nomeUsuario;
  final String nivelUsuario;
  final String? subtituloStreak;

  const PlantShareCard({
    super.key, 
    required this.planta,
    required this.nomeUsuario,
    required this.nivelUsuario,
    this.subtituloStreak,
  });

  ImageProvider _getImagemProvider() {
    final path = planta.imagemUrl;
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
    return Container(
      width: 350,
      decoration: const BoxDecoration(
        color: Color(0xFFa7c957),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF588157),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Imagem da Planta
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: _getImagemProvider(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Nome da Planta
                      Text(
                        planta.nome,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xfff2f2f2),
                          fontSize: 22, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // Box do Usuário
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF344e41),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFa7c957).withOpacity(0.3)
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, 
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center, 
                                children: [
                                  const Text(
                                    "Jardineiro(a):", 
                                    style: TextStyle(color: Colors.white70, fontSize: 12)
                                  ),
                                  Text(
                                    nomeUsuario,
                                    style: const TextStyle(
                                      color: Color(0xfff2f2f2), 
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 16
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Nível: $nivelUsuario", 
                                    style: const TextStyle(
                                      color: Color(0xFFa7c957), 
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold
                                    )
                                  ),
                                  
                                  if (subtituloStreak != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      subtituloStreak!,
                                      style: const TextStyle(
                                        color: Color(0xFFFF6D00),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Rodapé com Logo Aumentado
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center, // Alinha verticalmente
                        children: [
                          Text(
                            "Compartilhado via ",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Logo do GardenMe - Aumentado para 35
                          Image.asset(
                            'assets/images/logoGarden.png',
                            height: 30, 
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}