import 'package:flutter/material.dart';
import 'package:gardenme/components/curved_background.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key, required this.title});

  final String title;

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  @override
  Widget build(BuildContext context) {
    return curvedBackground(
      child: Container(
        padding: EdgeInsetsGeometry.all(20),
        child: Center(
          child: Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_vertical.png',
                width: 250,
                height: 250,
              ),
              SizedBox(
                width: 320,
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFf2f2f2),
                    label: Text("E-mail de usuário"),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF386641)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF386641)),
                    ),
                  ),
                ),
              ),

              SizedBox(
                width: 320,
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFf2f2f2),
                    label: Text("Senha"),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF386641)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF386641)),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsetsGeometry.all(20),
                child: Column(
                  spacing: 20,
                  children: [
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff3A5A40),
                        ),
                        onPressed: () {},
                        child: Text(
                          "Entrar",
                          style: TextStyle(color: Color(0xFFa7c957)),
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xfff2f2f2),
                        ),
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Entrar com "),
                            Image.asset(
                              'assets/images/google.png',
                              width: 25,
                              height: 25,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
