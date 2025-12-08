import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/pages/main_page.dart';
import 'package:gardenme/pages/password_recover.dart';
import 'package:gardenme/pages/register.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _senhaVisivel = false;

  Future<void> _fazerLogin() async {
    // Validação simples
    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha e-mail e senha.')),
      );
      return;
    }

    try {
      // Tenta fazer o login no Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      // Se der certo, vai para a tela principal
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
          (route) => false, // Remove as telas de login/cadastro da pilha
        );
      }
    } on FirebaseAuthException catch (e) {
      String erro = 'Erro ao fazer login.';

      // Tratamento de erros comuns
      if (e.code == 'user-not-found') {
        erro = 'Usuário não encontrado. Verifique o e-mail.';
      } else if (e.code == 'wrong-password') {
        erro = 'Senha incorreta.';
      } else if (e.code == 'invalid-email') {
        erro = 'E-mail inválido.';
      } else if (e.code == 'user-disabled') {
        erro = 'Este usuário foi desativado.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erro), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return curvedBackground(
      showHeader: false,
      child: Container(
        padding: EdgeInsetsGeometry.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logoLogin.png',
                  width: 200,
                  height: 200,
                ),
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFf2f2f2),
                      label: Text("E-mail de usuário"),
                      labelStyle: TextStyle(color: Color(0xFF386641)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Colors.black),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Color(0xFF386641)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Color(0xFF386641)),
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _senhaController,
                    obscureText: !_senhaVisivel,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFf2f2f2),
                      label: Text("Senha"),
                      labelStyle: TextStyle(color: Color(0xFF386641)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Color(0xFF386641)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _senhaVisivel
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF386641),
                        ),
                        onPressed: () {
                          setState(() {
                            _senhaVisivel = !_senhaVisivel;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                text: "Esqueceu sua ",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PasswordRecover(),
                                  ),
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: "senha?",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    fontSize: 16,
                                    color: Color(0xFF386641),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Row(
                          spacing: 0,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegisterAccount(),
                                  ),
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: "Cadastre-se.",
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xfff2f2f2),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
                          onPressed: _fazerLogin,
                          child: Text(
                            "Entrar",
                            style: TextStyle(
                              color: Color(0xFFf2f2f2),
                              fontSize: 16,
                            ),
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
                              Text(
                                "Entrar com ",
                                style: TextStyle(color: Color(0xff3A5A40)),
                              ),
                              Image.asset(
                                'assets/images/google.png',
                                width: 30,
                                height: 30,
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
      ),
    );
  }
}
