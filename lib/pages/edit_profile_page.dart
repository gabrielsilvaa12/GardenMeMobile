import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gardenme/components/curved_background.dart';

class EditProfilePage extends StatefulWidget {
  // CORREÇÃO: Tornado opcional (?) para aceitar usuários novos
  final Map<String, dynamic>? userData;

  const EditProfilePage({super.key, this.userData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late TextEditingController _nomeController;
  late TextEditingController _sobrenomeController;
  late TextEditingController _telefoneController;
  
  // Senhas (opcional, mantendo estrutura se quiser usar depois)
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  File? _imagemLocal;
  String? _fotoUrlAtual;
  bool _estaCarregando = false;
  bool _mostrarSenha = false;

  @override
  void initState() {
    super.initState();
    // Inicializa com dados ou vazio (Correção para tela branca)
    _nomeController = TextEditingController(text: widget.userData?['nome'] ?? '');
    _sobrenomeController = TextEditingController(text: widget.userData?['sobrenome'] ?? '');
    _telefoneController = TextEditingController(text: widget.userData?['telefone'] ?? '');
    _fotoUrlAtual = widget.userData?['foto_url'];
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _telefoneController.dispose();
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _selecionarImagem(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source, imageQuality: 50);
      if (image != null) {
        setState(() {
          _imagemLocal = File(image.path);
        });
      }
    } catch (e) {
      print("Erro ao selecionar imagem: $e");
    }
  }

  void _mostrarOpcoesFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 180,
          child: Column(
            children: [
              const Text("Escolha uma opção", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF386641)),
                title: const Text("Galeria"),
                onTap: () {
                  Navigator.pop(context);
                  _selecionarImagem(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF386641)),
                title: const Text("Câmera"),
                onTap: () {
                  Navigator.pop(context);
                  _selecionarImagem(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _salvar() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    
    if (_nomeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("O nome é obrigatório.")));
      return;
    }

    setState(() => _estaCarregando = true);

    try {
      String? urlFinal = _fotoUrlAtual;

      // 1. Upload da Imagem (se trocou)
      if (_imagemLocal != null) {
        final ref = _storage.ref().child('profile_images/$uid.jpg');
        await ref.putFile(_imagemLocal!);
        urlFinal = await ref.getDownloadURL();
      }

      Map<String, dynamic> dadosParaAtualizar = {
        'nome': _nomeController.text.trim(),
        'sobrenome': _sobrenomeController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'foto_url': urlFinal,
      };

      // CORREÇÃO CRÍTICA: set com merge cria o documento se não existir
      await _firestore.collection('usuarios').doc(uid).set(
        dadosParaAtualizar, 
        SetOptions(merge: true)
      );

      // Atualização de senha (Opcional)
      if (_novaSenhaController.text.isNotEmpty) {
        if (_novaSenhaController.text == _confirmarSenhaController.text) {
          if (_novaSenhaController.text.length < 6) throw "A senha deve ter pelo menos 6 caracteres.";
          await _auth.currentUser?.updatePassword(_novaSenhaController.text.trim());
        } else {
          throw "As novas senhas não coincidem.";
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perfil salvo com sucesso!")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (msg.contains("requires-recent-login")) msg = "Faça login novamente para trocar a senha.";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $msg")));
      }
    } finally {
      if (mounted) setState(() => _estaCarregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double tecladoAltura = MediaQuery.of(context).viewInsets.bottom;
    
    ImageProvider? imageProvider;
    if (_imagemLocal != null) {
      imageProvider = FileImage(_imagemLocal!);
    } else if (_fotoUrlAtual != null && _fotoUrlAtual!.isNotEmpty) {
      imageProvider = NetworkImage(_fotoUrlAtual!);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFa7c957),
      body: curvedBackground(
        showHeader: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(25, 25, 25, tecladoAltura > 0 ? tecladoAltura + 20 : 100),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xff588157),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 15, offset: const Offset(0, 10))],
            ),
            child: Column(
              children: [
                const Text("Editar Perfil", style: TextStyle(color: Color(0xFFf2f2f2), fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),

                GestureDetector(
                  onTap: _mostrarOpcoesFoto,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: const Color(0xFFa7c957).withOpacity(0.5),
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: const Color(0xfff2f2f2),
                          backgroundImage: imageProvider,
                          child: imageProvider == null ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
                        ),
                      ),
                      const Positioned(
                        bottom: 0, right: 0,
                        child: CircleAvatar(
                          backgroundColor: Color(0xff386641),
                          radius: 18,
                          child: Icon(Icons.camera_alt, color: Color(0xfff2f2f2), size: 18),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),
                _buildInput(_nomeController, "Nome"),
                const SizedBox(height: 15),
                _buildInput(_sobrenomeController, "Sobrenome (opcional)"),
                const SizedBox(height: 15),
                _buildInput(_telefoneController, "Telefone", teclado: TextInputType.phone),

                const SizedBox(height: 30),
                const Divider(color: Colors.white24, thickness: 1),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Segurança", style: TextStyle(color: Color(0xFFf2f2f2), fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 15),

                _buildInput(_senhaAtualController, "Senha atual", obscure: !_mostrarSenha, sufixo: IconButton(
                  icon: Icon(_mostrarSenha ? Icons.visibility : Icons.visibility_off, color: const Color(0xff386641)),
                  onPressed: () => setState(() => _mostrarSenha = !_mostrarSenha),
                )),
                const SizedBox(height: 15),
                _buildInput(_novaSenhaController, "Nova senha", obscure: !_mostrarSenha, sufixo: IconButton(
                  icon: Icon(_mostrarSenha ? Icons.visibility : Icons.visibility_off, color: const Color(0xff386641)),
                  onPressed: () => setState(() => _mostrarSenha = !_mostrarSenha),
                )),
                const SizedBox(height: 15),
                _buildInput(_confirmarSenhaController, "Confirmar nova senha", obscure: !_mostrarSenha, sufixo: IconButton(
                  icon: Icon(_mostrarSenha ? Icons.visibility : Icons.visibility_off, color: const Color(0xff386641)),
                  onPressed: () => setState(() => _mostrarSenha = !_mostrarSenha),
                )),

                const SizedBox(height: 40),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA7C957),
                    foregroundColor: const Color(0xFF3A5A40),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _estaCarregando ? null : _salvar,
                  child: _estaCarregando
                      ? const CircularProgressIndicator(color: Color(0xFF3A5A40))
                      : const Text("Salvar Alterações", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, {TextInputType teclado = TextInputType.text, bool obscure = false, Widget? sufixo}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFf2f2f2), fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: teclado,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            suffixIcon: sufixo,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }
}