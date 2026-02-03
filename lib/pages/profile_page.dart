import 'package:flutter/material.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/components/profile_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      backgroundColor: const Color(0xFFa7c957),
      body: curvedBackground(
        child: const SingleChildScrollView(
          // PADRONIZAÇÃO: Laterais alteradas de 20 para 24. Topo mantido em 24.
          padding: EdgeInsets.fromLTRB(24, 24, 24, 150),
          child: ProfileCard(),
        ),
      ),
    );
  }
}