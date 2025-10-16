import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DetailsPlantCard extends StatelessWidget {
  const DetailsPlantCard({super.key});
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
              Center(
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: const Color(0xFFa7c957),
                  child: const CircleAvatar(
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
                children: [
                  Expanded(
                    child: _buildInfoIcon(Icons.wb_sunny_outlined, '1 hora'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildInfoIcon(Icons.water_drop_outlined, '400 ml'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _buildInfoIcon(Icons.ac_unit, 'Outono')),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Dicas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDicaText('Rega: ', 'Duas vezes por dia.'),
              _buildDicaText('Fertilização: ', 'Húmus Líquido: 3x por semana.'),
              _buildDicaText('Terra: ', 'Terra comum; Húmus + Vermiculita.'),
            ],
          ),
          Positioned(
            top: -10,
            right: -10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF3A5A40), // Verde mais escuro
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

  Widget _buildInfoIcon(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0XFFa7c957),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDicaText(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(color: Colors.white, fontSize: 16),
          children: [
            TextSpan(
              text: title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: description),
          ],
        ),
      ),
    );
  }
}
