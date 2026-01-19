import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gardenme/models/planta.dart';
import 'package:gardenme/services/planta_service.dart';
import 'package:gardenme/pages/main_page.dart';

class DetailedPlant extends StatefulWidget {
  final Planta planta;

  const DetailedPlant({
    super.key,
    required this.planta,
  });

  @override
  State<DetailedPlant> createState() => _DetailedPlantState();
}

class _DetailedPlantState extends State<DetailedPlant> {
  final PlantaService _plantaService = PlantaService();
  
  bool _isEditing = false;
  late TextEditingController _nomeController;
  File? _novaImagemFile;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.planta.nome);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE FOTO (MODAL CÂMERA/GALERIA) ---
  
  // Função genérica para pegar imagem
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _novaImagemFile = File(image.path);
        });
      }
    } catch (e) {
      print("Erro ao selecionar imagem: $e");
    }
  }

  // Modal para escolher a origem da foto
  void _mostrarOpcoesFoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF588157), // Verde do tema
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4, 
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(2)),
              ),
              const Text(
                "Atualizar Foto",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOptionButton(
                    icon: Icons.camera_alt, 
                    label: "Câmera", 
                    onTap: () {
                      Navigator.pop(context); // Fecha o modal
                      _pickImage(ImageSource.camera);
                    }
                  ),
                  _buildOptionButton(
                    icon: Icons.photo_library, 
                    label: "Galeria", 
                    onTap: () {
                      Navigator.pop(context); // Fecha o modal
                      _pickImage(ImageSource.gallery);
                    }
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // --- LÓGICA DE SALVAR/EDITAR ---

  Future<void> _salvarEdicao() async {
    setState(() => _isEditing = false); 

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Salvando alterações..."), duration: Duration(seconds: 1)),
    );

    try {
      await _plantaService.editarPlanta(
        widget.planta, 
        _nomeController.text.trim(), 
        _novaImagemFile
      );
      
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Planta atualizada! 🌱"), backgroundColor: Color(0xff386641)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
      }
    }
  }

  void _confirmarExclusao() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xfff2f2f2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFE63946)),
              SizedBox(width: 10),
              Text("Excluir Planta?", style: TextStyle(color: Color(0xFF3A5A40), fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            "Tem certeza que deseja remover a ${widget.planta.nome}? \n\nTodos os dados serão apagados.",
            style: const TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _plantaService.removerPlanta(widget.planta);
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage(initialIndex: 1)),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE63946),
                foregroundColor: Colors.white,
              ),
              child: const Text("Sim, Excluir"),
            ),
          ],
        );
      },
    );
  }

  ImageProvider _getImagemProvider() {
    if (_novaImagemFile != null) {
      return FileImage(_novaImagemFile!);
    }
    if (widget.planta.imagemUrl != null && widget.planta.imagemUrl!.isNotEmpty) {
      return NetworkImage(widget.planta.imagemUrl!);
    }
    return const AssetImage('assets/images/logoGarden.png');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // --- CONTEÚDO PRINCIPAL ---
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            
            // Área da Imagem
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: _getImagemProvider(),
                    backgroundColor: Colors.white,
                  ),
                ),
                
                // Ícone de Câmera (Só aparece no modo edição)
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _mostrarOpcoesFoto, // Abre o Modal
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF386641),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Nome da Planta (Texto ou Input)
            if (_isEditing)
              Container(
                width: 250,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white),
                ),
                child: TextField(
                  controller: _nomeController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3A5A40)),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Nome da planta",
                  ),
                ),
              )
            else
              Text(
                widget.planta.nome,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF3A5A40)),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 24),
            
            // Indicadores
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIndicator(
                  label: "ESTADO ATUAL",
                  value: widget.planta.status,
                  icon: Icons.favorite,
                  color: const Color(0xFFE63946),
                ),
                Container(width: 1, height: 40, color: Colors.black12),
                _buildIndicator(
                  label: "MELHOR ÉPOCA",
                  value: widget.planta.estacaoIdeal ?? "Ano todo",
                  icon: Icons.wb_sunny,
                  color: const Color(0xFFF4A261),
                ),
              ],
            ),

            const SizedBox(height: 30),
            
            _buildInfoCard(
              title: "Como deixar a terra?",
              content: widget.planta.regaDica ?? "Terra levemente úmida.",
              icon: Icons.water_drop,
              color: const Color(0xFF81D4FA),
            ),

            _buildInfoCard(
              title: "Qual terra usar?",
              content: widget.planta.tipoTerra ?? "Terra Vegetal.",
              icon: Icons.grass, 
              color: const Color(0xFFA5D6A7),
            ),

            _buildInfoCard(
              title: "O que comprar?",
              content: widget.planta.dicaFertilizante ?? "Húmus de Minhoca.",
              icon: Icons.shopping_bag,
              color: const Color(0xFFFFCC80),
            ),

            const SizedBox(height: 40),

            // Botão Excluir
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: _confirmarExclusao,
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                label: const Text(
                  "EXCLUIR PLANTA",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE63946),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),

        // --- BOTÃO DE EDIÇÃO/SALVAR (CANTO SUPERIOR DIREITO) ---
        Positioned(
          top: 0,
          right: 0,
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  if (_isEditing) {
                    _salvarEdicao();
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isEditing ? const Color(0xFF386641) : Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))
                    ],
                  ),
                  child: Icon(
                    _isEditing ? Icons.check : Icons.edit,
                    color: _isEditing ? Colors.white : const Color(0xFF386641),
                    size: 26,
                  ),
                ),
              ),
              
              // Texto "SALVAR" que aparece somente no modo edição
              if (_isEditing)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "Salvar",
                    style: TextStyle(
                      fontSize: 10, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF386641)
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator({required String label, required String value, required IconData icon, required Color color}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF3A5A40))),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required String content, required IconData icon, required Color color}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.black87, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(content.toUpperCase(), style: const TextStyle(fontSize: 16, color: Color(0xFF3A5A40), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}