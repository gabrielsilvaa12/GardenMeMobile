import 'package:flutter/material.dart';
import 'package:gardenme/components/curved_background.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return curvedBackground(
      child: SingleChildScrollView(
        child: Container(
          width: 20,
          decoration: BoxDecoration(color: Color(0xff588157)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 48),
            child: Column(
              children: [
                Row(
                  children: [
                    Text("Tema", style: TextStyle(color: Color(0xfff2f2f2))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
