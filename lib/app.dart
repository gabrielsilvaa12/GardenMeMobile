import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gardenme/pages/login.dart';
import 'package:gardenme/pages/main_page.dart'; // Importante para redirecionar para a Home

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
      // AQUI ESTÁ A MÁGICA DA PERSISTÊNCIA
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), // Ouve mudanças no login
        builder: (context, snapshot) {
          // 1. Enquanto verifica o login no disco, mostra um carregando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFFa7c957),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF3A5A40)),
              ),
            );
          }
          
          // 2. Se encontrou um usuário (snapshot tem dados), vai direto pra Home
          if (snapshot.hasData) {
            return const MainPage();
          }
          
          // 3. Se não tem usuário (null), manda para o Login
          return const MyLogin();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}