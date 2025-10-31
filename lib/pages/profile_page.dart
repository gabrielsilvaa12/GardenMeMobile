import 'package:flutter/material.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/components/profile_card.dart';
import 'package:gardenme/components/navbar_card.dart'; // 1. Importe o NavbarCard

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFa7c957),

      body: curvedBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: const ProfileCard(),
        ),
      ),

      bottomNavigationBar: const NavbarCard(
        selectedIndex: 0,
      ), // 0 é o índice de "Perfil"
    );
  }
}
