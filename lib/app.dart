import 'package:flutter/material.dart';
import 'package:gardenme/pages/login.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GardenMe',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyLogin(),
      debugShowCheckedModeBanner: false,
    );
  }
}
