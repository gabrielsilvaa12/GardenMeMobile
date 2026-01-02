import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/pages/login.dart';

// Importe o seu model aqui (ajuste o caminho se necessário)
// import 'package:gardenme/models/user_model.dart';

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

  Future<void> _cadastrarUsuario() async {
    // 1. Validações Básicas (RN02: Senha mínima 6 caracteres)
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
      // 2. Criar usuário no Firebase Authentication (RF01)
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _senhaController.text.trim(),
          );

      // 3. Salvar dados adicionais no Firestore (Bloco 1 - Usuário)
      String userId = userCredential.user!.uid;

      // Usando a estrutura de campos definida para o Bloco 1 e 3
      await FirebaseFirestore.instance.collection('usuarios').doc(userId).set({
        'id': userId,
        'nome': _nomeController.text.trim(),
        'sobrenome': _sobrenomeController.text.trim(),
        'email': _emailController.text.trim(),
        'telefone': _celularController.text.trim(),
        'foto_url': null, // Inicialmente nulo (Bloco 3 cuidará do upload)
        'nivel': 'Iniciante', // Gamificação Inicial (RF11)
        'pontos': 0, // Gamificação Inicial (RF11)
        'criadoEm': FieldValue.serverTimestamp(), // Para auditoria (RNF09)
      });

      if (mounted) {
        _mostrarSnackBar(
          'Conta criada com sucesso!',
          cor: const Color(0xff6a994e),
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
      _mostrarSnackBar(erro, cor: Colors.redAccent);
    } catch (e) {
      _mostrarSnackBar('Erro inesperado: $e');
    }
  }

  void _mostrarSnackBar(String mensagem, {Color cor = Colors.black87}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem), backgroundColor: cor));
  }

  @override
  void dispose() {
    // Limpar controladores da memória
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _emailController.dispose();
    _confirmaEmailController.dispose();
    _celularController.dispose();
    _senhaController.dispose();
    _confirmaSenhaController.dispose();
    super.dispose();
  }

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
                  'assets/images/logo_vertical.png',
                  width: 200,
                  height: 200,
                ),

                Column(
                  spacing: 0,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Cadastro de usuário",
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF2d2f2d),
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
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyLogin(),
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
                                color: Color(0xFF386641),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _nomeController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFf2f2f2),
                      label: Text("Nome"),
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
                    controller: _sobrenomeController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFf2f2f2),
                      label: Text("Sobrenome (Opcional)"),
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
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFf2f2f2),
                      label: Text("E-mail"),
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
                    controller: _confirmaEmailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFf2f2f2),
                      label: Text("Confirme o E-mail"),
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
                    controller: _celularController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFf2f2f2),
                      label: Text("Celular (Opcional)"),
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

                // Em register.dart
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _senhaController,
                    obscureText: !_senhaVisivel,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFf2f2f2),
                      label: const Text("Senha"),
                      labelStyle: const TextStyle(color: Color(0xFF386641)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Color(0xFF386641)),
                      ),

                      // Borda quando o campo é clicado (Foco)
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Color(0xFF386641)),
                      ),

                      // Borda genérica de fallback
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Colors.black),
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
                  width: 320,
                  child: TextField(
                    controller: _confirmaSenhaController,
                    obscureText: !_confirmaSenhaVisivel,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFf2f2f2),
                      label: Text("Confirme a senha"),
                      labelStyle: TextStyle(color: Color(0xFF386641)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Colors.black),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Color(0xFF386641)),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Color(0xFF386641)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _confirmaSenhaVisivel
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF386641),
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
                            backgroundColor: const Color(0xffA7C957),
                          ),
                          onPressed: _cadastrarUsuario,
                          child: const Text(
                            "Cadastrar",
                            style: TextStyle(
                              color: Color(0xFF2d2f2d),
                              fontSize: 16,
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
