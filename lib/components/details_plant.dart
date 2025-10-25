import 'package:flutter/material.dart';

class DetailedPlant extends StatelessWidget {
  const DetailedPlant({super.key});

  Widget _buildInfoIcon(IconData icon, String text) {
    return Container(
      height: 80,
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFa7c957),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDicaText(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xfff2e8cf),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF588157),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 75,
                  backgroundColor: Color(0xFFAFF695),
                  child: CircleAvatar(
                    radius: 65,
                    backgroundImage: AssetImage('assets/images/moranguito.png'),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Morango',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoIcon(Icons.wb_sunny_outlined, '1 hora'),
                  _buildInfoIcon(Icons.water_drop_outlined, '400 ml'),
                  _buildInfoIcon(Icons.ac_unit, 'Outono'),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                'Dicas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xfff2f2f2),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDicaText('Rega:', 'Duas vezes por dia.'),
              _buildDicaText('Fertilização:', 'Húmus Líquido: 3x por semana.'),
              _buildDicaText('Terra:', 'Terra comum; Húmus + Vermiculita.'),
            ],
          ),

          Positioned(
            top: -10,
            right: -10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF3A5A40),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
