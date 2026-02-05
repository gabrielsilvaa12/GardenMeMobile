import 'package:flutter/material.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/components/profile_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtém a altura da área segura inferior (barra de gestos/botões virtuais)
    final double safeBottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      backgroundColor: const Color(0xFFa7c957),
      body: curvedBackground(
        child: SingleChildScrollView(
          // Somamos o padding fixo (150) com a área segura do dispositivo
          padding: EdgeInsets.fromLTRB(24, 24, 24, 150 + safeBottomPadding),
          child: const ProfileCard(),
        ),
      ),
    );
  }
}