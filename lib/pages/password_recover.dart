import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import necessário para o Firebase
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/pages/login.dart';

class PasswordRecover extends StatefulWidget {
  const PasswordRecover({super.key});

  @override
  State<PasswordRecover> createState() => _PasswordRecoverState();
}

class _PasswordRecoverState extends State<PasswordRecover> {
  // Controller para capturar o e-mail digitado
  final _emailController = TextEditingController();
  bool _estaCarregando = false;

  // Função que envia o e-mail de recuperação
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
      // Comando do Firebase para reset de senha
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      // Modal de aviso que o e-mail foi enviado
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
                Navigator.pop(context); // Fecha o modal
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyLogin()),
                ); // Volta para o Login
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
                    controller: _emailController, // Conectando o controller
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
                        child: const Text(
                          " voltar ",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFFf2f2f2),
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
                      backgroundColor: const Color(0xff3A5A40),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _estaCarregando
                        ? null
                        : _enviarEmailRecuperacao, // Chamando a função
                    child: _estaCarregando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Recuperar",
                            style: TextStyle(
                              color: Color(0xFFf2f2f2),
                              fontSize: 16,
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
