import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/pages/login.dart';

class PasswordRecover extends StatefulWidget {
  const PasswordRecover({super.key});

  @override
  State<PasswordRecover> createState() => _PasswordRecoverState();
}

class _PasswordRecoverState extends State<PasswordRecover> {
  final _emailController = TextEditingController();
  bool _estaCarregando = false;

  // Cor de destaque solicitada (Verde Claro)
  final Color highlightColor = const Color(0xFFA7C957);
  // Cor padrão do tema escuro (Verde Escuro)
  final Color darkGreen = const Color(0xFF344e41);

  Future<void> _enviarEmailRecuperacao() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, digite o seu e-mail."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _estaCarregando = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("E-mail Enviado"),
          content: Text(
            "Um link de recuperação foi enviado para $email. Verifique a sua caixa de entrada.",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyLogin()),
                );
              },
              child: const Text(
                "Entendi",
                style: TextStyle(
                    color: Color(0xFF386641), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      String mensagemErro = "Ocorreu um erro. Tente novamente.";

      if (e.code == 'user-not-found') {
        mensagemErro = "Este e-mail não está cadastrado.";
      } else if (e.code == 'invalid-email') {
        mensagemErro = "O formato do e-mail é inválido.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(mensagemErro), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _estaCarregando = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return curvedBackground(
      showHeader: false,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logoLogin.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFf2f2f2),
                      label: const Text("E-mail de usuário"),
                      labelStyle: const TextStyle(color: Color(0xFF386641)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Color(0xFF386641)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Color(0xFF386641)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          " voltar ",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            // ALTERADO: Verde Claro
                            color: highlightColor,
                          ),
                        ),
                      ),
                      const Text(
                        "e entrar com e-mail e senha.",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // ALTERADO: Fundo Verde Claro (padrão claro)
                      backgroundColor: highlightColor,
                      // ALTERADO: Texto Verde Escuro
                      foregroundColor: darkGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _estaCarregando
                        ? null
                        : _enviarEmailRecuperacao,
                    child: _estaCarregando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Recuperar",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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