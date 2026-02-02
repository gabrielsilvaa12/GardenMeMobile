import 'package:flutter/material.dart';
import 'package:gardenme/components/header.dart';

class BodyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.45);
    path.quadraticBezierTo(
      size.width / 2.5,
      size.height,
      size.width,
      size.height * 0.9,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class curvedBackground extends StatelessWidget {
  final Widget child;
  final bool showHeader;

  const curvedBackground({
    super.key,
    required this.child,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // AQUI: Pega a cor do topo definida no ThemeService (scaffoldBackgroundColor)
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          if (showHeader) const Header(),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipPath(
                  clipper: BodyClipper(),
                  // AQUI: Pega a cor de baixo definida no ThemeService (primary)
                  child: Container(color: Theme.of(context).colorScheme.primary),
                ),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}