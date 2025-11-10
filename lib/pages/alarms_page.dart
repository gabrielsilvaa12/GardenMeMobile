import 'package:flutter/material.dart';
import 'package:gardenme/components/alarm_settings_card.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/components/add_alarm_modal.dart'; //

class AlarmsPage extends StatefulWidget {
  final String plantName;

  const AlarmsPage({super.key, required this.plantName});

  @override
  State<AlarmsPage> createState() => _AlarmsPageState();
}

class _AlarmsPageState extends State<AlarmsPage> {
  void _openAddAlarmModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AddAlarmModal(plantName: widget.plantName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFa7c957),
      body: curvedBackground(
        showHeader: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [AlarmSettingsCard(plantName: widget.plantName)],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddAlarmModal(context),
        backgroundColor: const Color(0xfff2f2f2),
        foregroundColor: const Color(0xff588157),
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
