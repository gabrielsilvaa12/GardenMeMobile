import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfilePage({super.key, required this.userData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nomeController;
  late TextEditingController _sobrenomeController;
  late TextEditingController _telefoneController;

  File? _imagemLocal;
  bool _estaCarregando = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.userData['nome']);
    _sobrenomeController = TextEditingController(
      text: widget.userData['sobrenome'] ?? '',
    );
    _telefoneController = TextEditingController(
      text: widget.userData['telefone'] ?? '',
    );
  }

  Future<void> _selecionarImagem(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName =
          "perfil_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final String localPath = path.join(directory.path, fileName);

      final File localImage = await File(pickedFile.path).copy(localPath);

      setState(() {
        _imagemLocal = localImage;
      });
    }
  }

  Future<void> _salvar() async {
    setState(() => _estaCarregando = true);
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      Map<String, dynamic> dadosParaAtualizar = {
        'nome': _nomeController.text.trim(),
        'sobrenome': _sobrenomeController.text.trim(),
        'telefone': _telefoneController.text.trim(),
      };

      if (_imagemLocal != null) {
        dadosParaAtualizar['foto_url'] = _imagemLocal!.path;
      }

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .update(dadosParaAtualizar);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _estaCarregando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao salvar: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFa7c957),
      body: curvedBackground(
        showHeader: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(25, 25, 25, 100),
          child: Container(
            // --- ESTILIZAÇÃO DO CARD VERDE ESCURO ---
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xff588157),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "Editar Perfil",
                  style: TextStyle(
                    color: Color(0xFFf2f2f2),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                GestureDetector(
                  onTap: _mostrarOpcoesFoto,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: const Color(
                          0xFFa7c957,
                        ).withOpacity(0.5),
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: Color(0xfff2f2f2),
                          backgroundImage: _imagemLocal != null
                              ? FileImage(_imagemLocal!)
                              : (widget.userData['foto_url'] != null &&
                                    widget.userData['foto_url']
                                        .toString()
                                        .startsWith('/'))
                              ? FileImage(File(widget.userData['foto_url']))
                              : const AssetImage('assets/images/garden.png')
                                    as ImageProvider,
                        ),
                      ),
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Color(0xff386641),
                          radius: 18,
                          child: Icon(
                            Icons.camera_alt,
                            color: Color(0xfff2f2f2),
                            size: 18,
                          ),
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
                _buildInput(
                  _telefoneController,
                  "Telefone",
                  teclado: TextInputType.phone,
                ),

                const SizedBox(height: 40),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFFA7C957,
                    ), // Botão verde claro
                    foregroundColor: const Color(0xFF3A5A40),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _estaCarregando ? null : _salvar,
                  child: _estaCarregando
                      ? const CircularProgressIndicator(
                          color: Color(0xFF3A5A40),
                        )
                      : const Text(
                          "Salvar Alterações",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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

  void _mostrarOpcoesFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Escolha uma opção",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xff386641),
              ),
              title: const Text("Galeria"),
              onTap: () {
                Navigator.pop(context);
                _selecionarImagem(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xff386641)),
              title: const Text("Câmera"),
              onTap: () {
                Navigator.pop(context);
                _selecionarImagem(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label, {
    TextInputType teclado = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFf2f2f2),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: teclado,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
