import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gardenme/models/planta.dart';
import 'package:gardenme/pages/alarms_page.dart';
import 'package:gardenme/pages/edit_plant_page.dart';
import 'package:gardenme/services/planta_service.dart';
import 'package:gardenme/services/theme_service.dart';

// Imports para o compartilhamento
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gardenme/components/plant_share_card.dart';

class DetailedPlant extends StatefulWidget {
  final Planta planta;

  const DetailedPlant({super.key, required this.planta});

  @override
  State<DetailedPlant> createState() => _DetailedPlantState();
}

class _DetailedPlantState extends State<DetailedPlant> {
  final PlantaService _plantaService = PlantaService();
  
  // Controlador para capturar a imagem
  final ScreenshotController _screenshotController = ScreenshotController();
  
  late String _nomeExibido;
  late String? _imagemExibida;
  late bool _regaAtual; 

  @override
  void initState() {
    super.initState();
    _nomeExibido = widget.planta.nome;
    _imagemExibida = widget.planta.imagemUrl;
    _regaAtual = widget.planta.rega; 
  }

  Future<void> _toggleRega() async {
    const Color snackBarBg = Colors.white;
    const Color snackBarText = Color(0xFF344e41);

    if (_regaAtual) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Você já cuidou desta planta hoje! 🌱',
            style: TextStyle(color: snackBarText, fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: snackBarBg,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return; 
    }

    await _plantaService.atualizarStatus(
      widget.planta.id, 
      rega: true,
    );
    
    setState(() {
      _regaAtual = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Planta regada com amor! 💧 +10 XP',
            style: TextStyle(color: snackBarText, fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: snackBarBg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // --- LÓGICA DE COMPARTILHAMENTO ---

  String? _obterSubtituloStreak(int dias) {
    if (dias >= 60) return "Que Não Falha";
    if (dias >= 45) return "Em Sintonia";
    if (dias >= 35) return "Raízes Profundas";
    if (dias >= 25) return "Implacável";
    if (dias >= 15) return "Sempre Verde";
    if (dias >= 5) return "Incansável";
    return null;
  }

  Future<void> _compartilharPlanta() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator(color: Colors.white));
      },
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      String nomeUsuario = "Jardineiro";
      String nivelUsuario = "Iniciante";
      String? subtituloStreak;

      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          final data = doc.data()!;
          nomeUsuario = data['nome'] ?? "Jardineiro";
          nivelUsuario = data['nivel'] ?? "Iniciante";
          int streakAtual = data['streak_atual'] ?? 0;
          subtituloStreak = _obterSubtituloStreak(streakAtual);
        }
      }

      if (mounted) Navigator.pop(context);

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Screenshot(
                  controller: _screenshotController,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: PlantShareCard(
                      planta: Planta(
                        id: widget.planta.id,
                        nome: _nomeExibido, // Usa o nome atualizado
                        imagemUrl: _imagemExibida, // Usa a imagem atualizada
                        rega: _regaAtual,
                        dataCriacao: widget.planta.dataCriacao,
                      ),
                      nomeUsuario: nomeUsuario,
                      nivelUsuario: nivelUsuario,
                      subtituloStreak: subtituloStreak,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Gerando imagem...",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                )
              ],
            ),
          );
        },
      );

      await Future.delayed(const Duration(milliseconds: 500));

      final imageBytes = await _screenshotController.capture();

      if (mounted) Navigator.pop(context);

      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/gardenme_share.png').create();
        await imagePath.writeAsBytes(imageBytes);

        await Share.shareXFiles(
          [XFile(imagePath.path)],
          text: 'Veja minha $_nomeExibido no GardenMe! 🌿',
        );
      }

    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao compartilhar: $e")),
        );
      }
    }
  }

  // --------------------------------------------------------

  Widget _buildPlantImage() {
    final imagePath = _imagemExibida ?? '';
    ImageProvider imgProvider;

    if (imagePath.startsWith('http')) {
      imgProvider = NetworkImage(imagePath);
    } else if (imagePath.isNotEmpty) {
      try {
        imgProvider = FileImage(File(imagePath));
      } catch (e) {
        imgProvider = const AssetImage('assets/images/garden.png');
      }
    } else {
      imgProvider = const AssetImage('assets/images/garden.png');
    }

    return Image(
      image: imgProvider,
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 250,
      color: Colors.white24,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 50, color: Colors.white54),
      ),
    );
  }

  Widget _buildInfoSection(String titulo, String conteudo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Color(0xFFa7c957),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            conteudo,
            style: const TextStyle(
              color: Color(0xfff2f2f2),
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirTelaEdicao() async {
    final plantaAtual = Planta(
      id: widget.planta.id,
      nome: _nomeExibido,
      imagemUrl: _imagemExibida,
      rega: _regaAtual,
      dataCriacao: widget.planta.dataCriacao,
      estacaoIdeal: widget.planta.estacaoIdeal,
      regaDica: widget.planta.regaDica,
      tipoTerra: widget.planta.tipoTerra,
      dicaFertilizante: widget.planta.dicaFertilizante,
    );

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPlantPage(planta: plantaAtual),
      ),
    );

    if (resultado != null && resultado is Map) {
      setState(() {
        _nomeExibido = resultado['novoNome'];
        _imagemExibida = resultado['novaImagem'];
      });
    }
  }

  void _irParaAlarmes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmsPage(
          plantName: _nomeExibido,
          plantaId: widget.planta.id,
        ),
      ),
    );
  }

  Future<void> _excluirPlanta() async {
    final isDark = ThemeService.instance.currentTheme == ThemeOption.escuro;

    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF344e41) : const Color(0xfff2f2f2),
        title: Text(
          "Excluir planta?",
          style: TextStyle(
            color: isDark ? const Color(0xfff2f2f2) : const Color(0xFF344e41),
            fontWeight: FontWeight.bold
          ),
        ),
        content: Text(
          "Isso apagará a planta e seus alarmes permanentemente.",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              "Cancelar",
              style: TextStyle(
                color: isDark ? const Color(0xFFA7C957) : const Color(0xFF344e41)
              ),
            )
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Excluir", 
              style: TextStyle(color: Color(0xFFbc4749), fontWeight: FontWeight.bold)
            )
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await _plantaService.removerPlanta(widget.planta);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Planta excluída com sucesso!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Color(0xFFbc4749), 
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context); 
      }
    }
  }

  String _formatarData(DateTime data) {
    String dia = data.day.toString().padLeft(2, '0');
    String mes = data.month.toString().padLeft(2, '0');
    String ano = data.year.toString();
    return "$dia/$mes/$ano";
  }

  @override
  Widget build(BuildContext context) {
    final estacao = widget.planta.estacaoIdeal ?? 'Ano todo';
    final umidade = widget.planta.regaDica ?? 'Verifique a umidade do solo regularmente.';
    final terra = widget.planta.tipoTerra ?? 'Terra vegetal preta rica em matéria orgânica.';
    final fertilizante = widget.planta.dicaFertilizante ?? 'Adubo orgânico ou NPK 10-10-10.';
    
    final isDark = ThemeService.instance.currentTheme == ThemeOption.escuro;

    return Column(
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF588157),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  _buildPlantImage(),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      children: [
                        // 1º - TOPO: Botão Rega
                        InkWell(
                          onTap: _toggleRega,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 50,
                            height: 50, 
                            decoration: BoxDecoration(
                              // Azul
                              color: _regaAtual
                                  ? const Color(0xFF81D4FA) 
                                  : const Color(0xFF81D4FA).withOpacity(0.5), 
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.water_drop_outlined, size: 24, color: Color(0xfff2f2f2)),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 2º - MEIO: Botão Alarmes
                        InkWell(
                          onTap: _irParaAlarmes,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              // COR SÓLIDA AGORA (Sem Opacidade)
                              color: const Color.fromARGB(255, 30, 56, 35).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.notifications_none_outlined,
                              color: Color(0xfff2f2f2), 
                              size: 24
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),

                        // 3º - BAIXO: Botão Compartilhar
                        InkWell(
                          onTap: _compartilharPlanta,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 50,
                            height: 50, 
                            decoration: BoxDecoration(
                              color: const Color(0xfff2f2f2),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.share_outlined, size: 24, color: Color(0xFF588157)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        _nomeExibido,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xfff2f2f2),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF344e41),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFa7c957).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, color: Color(0xFFa7c957)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Melhor época para plantar:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                Text(
                                  estacao,
                                  style: const TextStyle(color: Color(0xfff2f2f2), fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    _buildInfoSection("Umidade da terra:", umidade),
                    _buildInfoSection("Qual terra usar:", terra),
                    _buildInfoSection("Fertilizante ideal:", fertilizante),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _abrirTelaEdicao,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark 
                              ? const Color(0xFF344e41) 
                              : const Color(0xFFA7C957),
                          foregroundColor: isDark 
                              ? const Color(0xFFA7C957) 
                              : const Color(0xFF344e41),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4, 
                        ),
                        child: const Text(
                          "Editar Planta",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _excluirPlanta,
                        icon: const Icon(Icons.delete_outline, size: 26),
                        label: const Text(
                          "Excluir Planta", 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFbc4749),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (widget.planta.dataCriacao != null) ...[
          const SizedBox(height: 20),
          Text(
            "Adicionada em ${_formatarData(widget.planta.dataCriacao!)}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}