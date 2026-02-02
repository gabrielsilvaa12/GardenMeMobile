import 'package:flutter/material.dart';
import 'package:gardenme/services/planta_service.dart';
import 'package:gardenme/services/api_service.dart';

class AddPlantModal extends StatefulWidget {
  const AddPlantModal({super.key});

  @override
  State<AddPlantModal> createState() => _AddPlantModalState();
}

class _AddPlantModalState extends State<AddPlantModal> {
  final PlantaService _plantaService = PlantaService();
  final ApiService _apiService = ApiService();
  
  // Catálogo local (As 40 Plantas)
  late Map<String, List<Map<String, String>>> _catalogo;

  bool _isSaving = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _catalogo = _apiService.getCatalogoCompleto();
  }

  // Quando clica em um item do catálogo (ex: "Morango")
  // Buscamos automaticamente na API pelo termo técnico (ex: "Strawberry")
  Future<void> _selecionarDoCatalogo(String nomeExibicao, String termoBuscaApi) async {
    setState(() {
      _isSaving = true;
      _statusMessage = 'Buscando informações sobre "$nomeExibicao"...';
    });

    try {
      // 1. Pesquisa na API
      final resultados = await _apiService.pesquisarPlantas(termoBuscaApi);
      
      if (resultados.isNotEmpty) {
        // Pega o primeiro resultado (geralmente o mais preciso para os termos que curamos)
        final plantaApi = resultados.first;
        
        setState(() => _statusMessage = 'Baixando ficha técnica...');

        // Agora busca os detalhes (água, solo, etc)
        final detalhes = await _apiService.buscarDetalhesPorId(plantaApi['id']);
        
        setState(() => _statusMessage = 'Plantando no seu jardim...');

        await _plantaService.adicionarPlanta(
          nomeExibicao, // Salva com o nome em Português que está na lista
          detalhes['imagem_original'], // Foto da API
          dadosExtras: detalhes // Ficha técnica da API
        );

        _fecharComSucesso("$nomeExibicao adicionada com sucesso! 🌱");
      } else {
        // Fallback: Se a API falhar ou não achar, salva sem foto/dados extras
        await _plantaService.adicionarPlanta(nomeExibicao, null);
        _fecharComSucesso("$nomeExibicao adicionada (Modo Offline).");
      }

    } catch (e) {
      _tratarErro(e);
    }
  }

  void _fecharComSucesso(String msg) {
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Color(0xff386641), // Texto Verde Escuro
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xffa7c957), // Fundo Verde Claro
      ),
    );
  }

  void _tratarErro(Object e) {
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _statusMessage = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao adicionar: $e')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.85, 
      child: Container(
        padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 0),
        decoration: const BoxDecoration(
          color: Color(0xff588157),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // Título e Ícone decorativo
            const Icon(Icons.spa, color: Color(0xfff2f2f2), size: 32),
            const SizedBox(height: 10),
            const Text(
              'Escolha o que plantar',
              style: TextStyle(
                color: Color(0xfff2f2f2), 
                fontSize: 22, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Toque para adicionar ao seu jardim',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            
            // --- CONTEÚDO PRINCIPAL ---
            Expanded(
              child: _isSaving 
                  ? _buildLoadingState() // Tela de "Salvando..."
                  : _buildCatalogoView(), // Lista das 40 plantas
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: Colors.white),
        const SizedBox(height: 20),
        Text(
          _statusMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        )
      ],
    );
  }

  // Exibe o Catálogo Categorizado
  Widget _buildCatalogoView() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: _catalogo.entries.map((categoria) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: false, 
              tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              title: Text(
                categoria.key, // Ex: "Frutíferas para Vasos 🍓"
                style: const TextStyle(
                  color: Color(0xfff2f2f2), 
                  fontWeight: FontWeight.bold, 
                  fontSize: 18
                ),
              ),
              iconColor: const Color(0xfff2f2f2),
              collapsedIconColor: Colors.white70,
              children: categoria.value.map((planta) {
                return Column(
                  children: [
                    Divider(color: Colors.white.withOpacity(0.1), height: 1),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFA7C957),
                        radius: 18,
                        child: Icon(Icons.add, color: Color(0xff386641), size: 20),
                      ),
                      title: Text(
                        planta['nome']!, // Ex: "Morango"
                        style: const TextStyle(
                          color: Color(0xfff2f2f2), 
                          fontWeight: FontWeight.w500,
                          fontSize: 16
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
                      onTap: () => _selecionarDoCatalogo(planta['nome']!, planta['busca']!),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }
}