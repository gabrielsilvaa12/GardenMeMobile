import 'package:flutter/material.dart';
import 'package:gardenme/components/navbar_card.dart';
import 'package:gardenme/pages/home_page.dart';
import 'package:gardenme/pages/profile_page.dart';
import 'package:gardenme/pages/settings.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedPos = 1;

  final List<Widget> _pages = [
    const ProfilePage(),
    const MyHomePage(),
    Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,

      body: IndexedStack(index: selectedPos, children: _pages),

      bottomNavigationBar: NavbarCard(
        selectedIndex: selectedPos,
        onItemSelected: (index) {
          setState(() {
            selectedPos = index;
          });
        },
      ),
    );
  }
}
