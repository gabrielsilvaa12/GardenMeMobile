import 'package:flutter/material.dart';
import 'package:gardenme/components/navbar_card.dart';
import 'package:gardenme/pages/home_page.dart';
import 'package:gardenme/pages/profile_page.dart';
import 'package:gardenme/pages/settings.dart'; // Importa o arquivo correto

class MainPage extends StatefulWidget {
  final int initialIndex;

  const MainPage({
    super.key, 
    this.initialIndex = 1, // Começa na Home (Jardim) por padrão
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // Lista das páginas principais
  final List<Widget> _pages = [
    const ProfilePage(),      // Index 0
    const MyHomePage(),       // Index 1 (Home/Jardim)
    const Settings(),         // Index 2 (CORRIGIDO: Classe Settings)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFa7c957),
      
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      bottomNavigationBar: NavbarCard(
        selectedIndex: _currentIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}