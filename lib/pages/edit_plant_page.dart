import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gardenme/components/curved_background.dart';
import 'package:gardenme/models/planta.dart';
import 'package:gardenme/services/planta_service.dart';

class EditPlantPage extends StatefulWidget {
  final Planta planta;

  const EditPlantPage({super.key, required this.planta});

  @override
  State<EditPlantPage> createState() => _EditPlantPageState();
}

class _EditPlantPageState extends State<EditPlantPage> {
  final PlantaService _plantaService = PlantaService();
  late TextEditingController _nomeController;
  
  File? _novaImagemLocal;
  String? _caminhoImagemAtual;
  bool _estaCarregando = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.planta.nome);
    _caminhoImagemAtual = widget.planta.imagemUrl;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _selecionarImagem(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source, imageQuality: 50);
      if (image != null) {
        setState(() {
          _novaImagemLocal = File(image.path);
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
              const Text("Alterar foto da planta", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  ImageProvider _getImagemProvider() {
    if (_novaImagemLocal != null) {
      return FileImage(_novaImagemLocal!);
    }
    
    if (_caminhoImagemAtual != null && _caminhoImagemAtual!.isNotEmpty) {
      if (_caminhoImagemAtual!.startsWith('http')) {
        return NetworkImage(_caminhoImagemAtual!);
      }
      try {
        return FileImage(File(_caminhoImagemAtual!));
      } catch (e) {
        return const AssetImage('assets/images/garden.png');
      }
    }
    return const AssetImage('assets/images/garden.png');
  }

  Future<void> _salvar() async {
    if (_nomeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("O nome é obrigatório.")));
      return;
    }

    setState(() => _estaCarregando = true);

    try {
      String? caminhoFinal = _caminhoImagemAtual;

      // Se selecionou nova imagem, usamos o novo caminho local
      if (_novaImagemLocal != null) {
        caminhoFinal = _novaImagemLocal!.path;
      }

      await _plantaService.atualizarPlanta(
        widget.planta.id, 
        _nomeController.text.trim(), 
        caminhoFinal
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Planta atualizada! 🌱")));
        // Retorna os novos dados para a tela anterior atualizar imediatamente
        Navigator.pop(context, {
          'novoNome': _nomeController.text.trim(),
          'novaImagem': caminhoFinal
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao salvar: $e")));
      }
    } finally {
      if (mounted) setState(() => _estaCarregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFa7c957),
      body: curvedBackground(
        showHeader: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xff588157),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 15, offset: const Offset(0, 10))],
            ),
            child: Column(
              children: [
                const Text("Editar Planta", style: TextStyle(color: Color(0xFFf2f2f2), fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),

                GestureDetector(
                  onTap: _mostrarOpcoesFoto,
                  child: Stack(
                    children: [
                      Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: const Color(0xFFa7c957).withOpacity(0.5),
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: _getImagemProvider(),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(color: const Color(0xfff2f2f2), width: 3),
                        ),
                      ),
                      const Positioned(
                        bottom: 0, right: 0,
                        child: CircleAvatar(
                          backgroundColor: Color(0xff386641),
                          radius: 20,
                          child: Icon(Icons.camera_alt, color: Color(0xfff2f2f2), size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Nome da Planta", style: TextStyle(color: Color(0xFFf2f2f2), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nomeController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),

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
                
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar", style: TextStyle(color: Color(0xfff2f2f2))),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}