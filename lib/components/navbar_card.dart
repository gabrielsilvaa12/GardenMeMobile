import 'package:flutter/material.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:gardenme/pages/home_page.dart';
import 'package:gardenme/pages/profile_page.dart';

class NavbarCard extends StatefulWidget {
  final int selectedIndex;

  const NavbarCard({super.key, required this.selectedIndex});

  @override
  State<NavbarCard> createState() => _NavbarCardState();
}

class _NavbarCardState extends State<NavbarCard> {
  late CircularBottomNavigationController _navigationController;

  final List<TabItem> tabItems = [
    TabItem(
      Icons.person,
      "Perfil",
      const Color(0XFF386641),
      labelStyle: const TextStyle(
        color: Color(0xFF3A5A40),
        fontWeight: FontWeight.bold,
      ),
    ),
    TabItem(
      Icons.local_florist,
      "Jardim",
      const Color(0XFF386641),
      labelStyle: const TextStyle(
        color: Color(0xFF3A5A40),
        fontWeight: FontWeight.bold,
      ),
    ),
    TabItem(
      Icons.settings,
      "Configurações",
      const Color(0XFF386641),
      labelStyle: const TextStyle(
        color: Color(0xFF3A5A40),
        fontWeight: FontWeight.bold,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _navigationController = CircularBottomNavigationController(
      widget.selectedIndex,
    );
  }

  @override
  void dispose() {
    _navigationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CircularBottomNavigation(
      tabItems,
      controller: _navigationController,
      barHeight: 70,
      circleSize: 70,
      iconsSize: 35,
      barBackgroundColor: const Color(0xfff2e8cf),
      animationDuration: const Duration(milliseconds: 300),
      selectedPos: widget.selectedIndex,
      selectedCallback: (int? newIndex) {
        if (newIndex == null) return;

        if (newIndex == widget.selectedIndex) return;

        switch (newIndex) {
          case 0:
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    const ProfilePage(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    const MyHomePage(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
            break;
          case 2:
            // Navigator.pushReplacement(
            //   context,
            //   PageRouteBuilder(
            //     pageBuilder: (context, animation1, animation2) => const SettingsPage(),
            //     transitionDuration: Duration.zero,
            //     reverseTransitionDuration: Duration.zero,
            //   ),
            // );
            break;
        }
      },
    );
  }
}
