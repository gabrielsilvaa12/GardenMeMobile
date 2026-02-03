import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gardenme/models/planta.dart';

class PlantShareCard extends StatelessWidget {
  final Planta planta;
  final String nomeUsuario;
  final String nivelUsuario;

  const PlantShareCard({
    super.key, 
    required this.planta,
    required this.nomeUsuario,
    required this.nivelUsuario,
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
    // Container principal que simula o visual do details_plant
    return Container(
      width: 350, // Largura fixa para garantir consistência no compartilhamento
      decoration: BoxDecoration(
        color: const Color(0xFFa7c957), // Fundo da tela (verde claro)
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Card Verde Escuro (Igual ao DetailedPlant)
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
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // Box do Usuário (Estilo parecido com "Melhor época")
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
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0xFFa7c957),
                              radius: 20,
                              child: Icon(Icons.person, color: Color(0xFF344e41)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Logo ou Marca d'água
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.spa, color: Colors.white54, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            "Compartilhado via GardenMe",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              letterSpacing: 1.1
                            ),
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