import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/pages/login.dart';
import 'package:gardenme/services/theme_service.dart';

class RegisterAccount extends StatefulWidget {
  const RegisterAccount({super.key});

  @override
  State<RegisterAccount> createState() => _MyLoginState();
}

class _MyLoginState extends State<RegisterAccount> {
  final _nomeController = TextEditingController();
  final _sobrenomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _confirmaEmailController = TextEditingController();
  final _celularController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmaSenhaController = TextEditingController();

  bool _senhaVisivel = false;
  bool _confirmaSenhaVisivel = false;

  // Cor de destaque (Verde Claro)
  final Color highlightColor = const Color(0xFFA7C957);
  // Cor padrão dos labels e textos escuros (Verde Escuro - Ajustado para #344e41)
  final Color darkGreen = const Color(0xFF344e41);

  Future<void> _cadastrarUsuario() async {
    if (_nomeController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _senhaController.text.isEmpty) {
      _mostrarSnackBar('Preencha os campos obrigatórios!');
      return;
    }

    if (_senhaController.text.length < 6) {
      _mostrarSnackBar('A senha deve ter no mínimo 6 caracteres.');
      return;
    }

    if (_emailController.text.trim() != _confirmaEmailController.text.trim()) {
      _mostrarSnackBar('Os e-mails não coincidem!');
      return;
    }

    if (_senhaController.text != _confirmaSenhaController.text) {
      _mostrarSnackBar('As senhas não coincidem!');
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      String userId = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('usuarios').doc(userId).set({
        'id': userId,
        'nome': _nomeController.text.trim(),
        'sobrenome': _sobrenomeController.text.trim(),
        'email': _emailController.text.trim(),
        'telefone': _celularController.text.trim(),
        'foto_url': null,
        'nivel': 'Iniciante',
        'pontos': 0,
        'criadoEm': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // SUCESSO: Fundo Branco e Texto Verde Escuro (Fixo para ambos os temas)
        _mostrarSnackBar(
          'Conta criada com sucesso!',
          cor: Colors.white,
          textoCor: darkGreen,
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MyLogin()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String erro = 'Erro ao cadastrar';
      if (e.code == 'weak-password') {
        erro = 'A senha é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        erro = 'Este e-mail já está em uso.';
      } else if (e.code == 'invalid-email') {
        erro = 'O formato do e-mail é inválido.';
      }
      // ERRO: Vermelho (Mantedo padrão)
      _mostrarSnackBar(erro, cor: Colors.redAccent);
    } catch (e) {
      _mostrarSnackBar('Erro inesperado: $e');
    }
  }

  void _mostrarSnackBar(String mensagem,
      {Color cor = Colors.black87, Color textoCor = Colors.white}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensagem,
          style: TextStyle(color: textoCor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: cor,
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _emailController.dispose();
    _confirmaEmailController.dispose();
    _celularController.dispose();
    _senhaController.dispose();
    _confirmaSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Verifica o tema atual
    final isDark = ThemeService.instance.currentTheme == ThemeOption.escuro;

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
                  'assets/images/logo_vertical.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Cadastro de usuário",
                          style: TextStyle(
                            fontSize: 20,
                            color: isDark ? highlightColor : darkGreen,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: "Já possui uma conta? Faça o ",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyLogin(),
                              ),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "login.",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _nomeController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFf2f2f2),
                      label: const Text("Nome"),
                      labelStyle: TextStyle(color: darkGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: darkGreen),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: darkGreen),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _sobrenomeController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFf2f2f2),
                      label: const Text("Sobrenome (Opcional)"),
                      labelStyle: TextStyle(color: darkGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: darkGreen),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: darkGreen),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFf2f2f2),
                      label: const Text("E-mail"),
                      labelStyle: TextStyle(color: darkGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: darkGreen),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: darkGreen),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _confirmaEmailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFf2f2f2),
                      label: const Text("Confirme o E-mail"),
                      labelStyle: TextStyle(color: darkGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: darkGreen),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: darkGreen),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _celularController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFf2f2f2),
                      label: const Text("Celular (Opcional)"),
                      labelStyle: TextStyle(color: darkGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: darkGreen),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: darkGreen),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _senhaController,
                    obscureText: !_senhaVisivel,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFf2f2f2),
                      label: const Text("Senha"),
                      labelStyle: TextStyle(color: darkGreen),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: darkGreen),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: darkGreen),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _senhaVisivel
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: darkGreen,
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
                const SizedBox(height: 20),
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _confirmaSenhaController,
                    obscureText: !_confirmaSenhaVisivel,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFf2f2f2),
                      label: const Text("Confirme a senha"),
                      labelStyle: TextStyle(color: darkGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: darkGreen),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: darkGreen),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _confirmaSenhaVisivel
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: darkGreen,
                        ),
                        onPressed: () {
                          setState(() {
                            _confirmaSenhaVisivel = !_confirmaSenhaVisivel;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: highlightColor,
                            foregroundColor: darkGreen,
                          ),
                          onPressed: _cadastrarUsuario,
                          child: const Text(
                            "Cadastrar",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}