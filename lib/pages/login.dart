import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/pages/main_page.dart';
import 'package:gardenme/pages/password_recover.dart';
import 'package:gardenme/pages/register.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _senhaVisivel = false;

  Future<void> _fazerLoginGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;

      if (user == null) {
        debugPrint("USER NULL APÓS LOGIN");
        return;
      }

      debugPrint("UID LOGADO: ${user.uid}");

      final userDoc =
          FirebaseFirestore.instance.collection('usuarios').doc(user.uid);

      final snap = await userDoc.get();

      if (!snap.exists) {
        debugPrint("CRIANDO PERFIL NO FIRESTORE");

        await userDoc.set({
          'nome': user.displayName?.split(" ").first ?? 'Usuário',
          'sobrenome': user.displayName?.split(" ").skip(1).join(" "),
          'email': user.email,
          'pontos': 0,
          'streak_atual': 0,
          'melhor_streak': 0,
          'plantas_count': 0,
          'regas_count': 0,
          'foto_url': '',
          'ultima_rega_data': null,
          'criado_em': FieldValue.serverTimestamp(),
        });

        debugPrint("PERFIL CRIADO COM SUCESSO");
      } else {
        debugPrint("PERFIL JÁ EXISTE");
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
        (_) => false,
      );
    } catch (erro) {
      debugPrint("ERRO GOOGLE LOGIN: $erro");
    }
  }

  Future<void> _fazerLogin() async {
    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha e-mail e senha')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      String erro = 'Erro ao fazer login';

      if (e.code == 'user-not-found') {
        erro = 'Usuário não encontrado';
      } else if (e.code == 'wrong-password') {
        erro = 'Senha incorreta';
      } else if (e.code == 'invalid-email') {
        erro = 'E-mail inválido';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: Colors.redAccent),
      );
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
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logoLogin.png',
                  width: 200,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFf2f2f2),
                      labelText: "E-mail",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _senhaController,
                    obscureText: !_senhaVisivel,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFf2f2f2),
                      labelText: "Senha",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _senhaVisivel
                              ? Icons.visibility
                              : Icons.visibility_off,
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
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PasswordRecover(),
                      ),
                    );
                  },
                  child: const Text(
                    "Esqueceu sua senha?",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Color(0xFF386641),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: _fazerLogin,
                    child: const Text("Entrar"),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xfff2f2f2),
                    ),
                    onPressed: _fazerLoginGoogle,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Entrar com ",
                          style: TextStyle(color: Color(0xff3A5A40)),
                        ),
                        Image.asset(
                          'assets/images/google.png',
                          width: 28,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegisterAccount(),
                      ),
                    );
                  },
                  child: const Text(
                    "Cadastre-se",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.white,
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
