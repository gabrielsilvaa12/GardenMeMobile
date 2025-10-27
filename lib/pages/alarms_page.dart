import 'package:flutter/material.dart';
import 'package:gardenme/components/alarm_settings_card.dart';
import 'package:gardenme/components/curved_background.dart';

class AlarmsPage extends StatelessWidget {
  final String plantName;

  const AlarmsPage({super.key, required this.plantName});

  @override
  Widget build(BuildContext context) {
    return curvedBackground(
      showHeader: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [AlarmSettingsCard(plantName: plantName)],
        ),
      ),
    );
  }
}
