import 'package:flutter/material.dart';

class GamificationModal extends StatelessWidget {
  const GamificationModal({super.key});

  @override
  Widget build(BuildContext context) {
    // Captura a área segura inferior
    final double bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      // Padding dinâmico: 40 (padrão) + área segura do celular
      padding: EdgeInsets.fromLTRB(24, 12, 24, 40 + bottomPadding),
      decoration: const BoxDecoration(
        color: Color(0xff588157),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra de arraste do modal
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Sistema de Pontos",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),

          // Itens explicativos
          _buildInfoItem(
            Icons.water_drop,
            "Regas",
            "Cada planta regada garante +10 pontos para o seu perfil.",
          ),
          _buildInfoItem(
            Icons.local_fire_department_rounded,
            "Foguinho (Streak)",
            "Regue pelo menos uma planta por dia para manter sua sequência. Se falhar um dia, o fogo apaga!",
          ),
          _buildInfoItem(
            Icons.trending_up_rounded,
            "Níveis",
            "Acumule pontos para subir de nível. A dificuldade aumenta conforme você evolui!",
          ),

          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA7C957),
              foregroundColor: const Color(0xFF3A5A40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              minimumSize: const Size(150, 45),
            ),
            child: const Text(
              "Entendi!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFA7C957), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}