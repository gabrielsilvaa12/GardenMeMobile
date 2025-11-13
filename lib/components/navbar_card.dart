import 'package:flutter/material.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';

typedef OnItemSelectedCallback = void Function(int index);

class NavbarCard extends StatefulWidget {
  final int selectedIndex;
  // 2. Use o typedef para o callback
  final OnItemSelectedCallback onItemSelected;

  const NavbarCard({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected, // Requer o callback
  });
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
  void didUpdateWidget(covariant NavbarCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _navigationController.value = widget.selectedIndex;
    }
  }

  @override
  void dispose() {
    _navigationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double bottomPadding = mediaQuery.padding.bottom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularBottomNavigation(
          tabItems,
          controller: _navigationController,
          barHeight: 70,
          circleSize: 70,
          iconsSize: 35,
          barBackgroundColor: const Color(0xfff2e8cf),
          animationDuration: const Duration(milliseconds: 300),
          selectedPos: widget.selectedIndex,
          selectedCallback: (int? newIndex) {
            if (newIndex != null) {
              widget.onItemSelected(newIndex);
            }
          },
        ),
        if (bottomPadding > 0 && mediaQuery.viewInsets.bottom == 0)
          Container(height: bottomPadding, color: const Color(0xfff2e8cf)),
      ],
    );
  }
}
