import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gardenme/models/planta.dart';
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
  
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  
  // Lista de resultados da BUSCA (API)
  List<Map<String, dynamic>> _resultadosBuscaApi = [];
  
  // Catálogo local (As 40 Plantas)
  late Map<String, List<Map<String, String>>> _catalogo;

  bool _isSearching = false; // Se o usuário está digitando
  bool _isLoadingSearch = false; // Se a API está buscando
  bool _isSaving = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _catalogo = _apiService.getCatalogoCompleto();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _resultadosBuscaApi = [];
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
      _isLoadingSearch = true;
    });

    _debounce = Timer(const Duration(milliseconds: 800), () async {
      final resultados = await _apiService.pesquisarPlantas(query);
      
      if (mounted) {
        setState(() {
          _resultadosBuscaApi = resultados;
          _isLoadingSearch = false;
        });
      }
    });
  }

  // Quando clica em um item do catálogo (ex: "Jabuticabeira")
  // Nós forçamos a busca na API usando o termo mapeado (ex: "Plinia cauliflora")
  // para garantir que venham os dados corretos.
  Future<void> _selecionarDoCatalogo(String nomeExibicao, String termoBuscaApi) async {
    setState(() {
      _isSaving = true;
      _statusMessage = 'Consultando jardineiro sobre "$nomeExibicao"...';
    });

    try {
      // 1. Pesquisa na API usando o termo técnico/inglês
      final resultados = await _apiService.pesquisarPlantas(termoBuscaApi);
      
      if (resultados.isNotEmpty) {
        // Pega o primeiro resultado (geralmente o mais preciso)
        final plantaApi = resultados.first;
        
        // Agora busca os detalhes (água, solo, etc)
        final detalhes = await _apiService.buscarDetalhesPorId(plantaApi['id']);
        
        setState(() => _statusMessage = 'Salvando no jardim...');

        await _plantaService.adicionarPlanta(
          nomeExibicao, // Salva com o nome em Português (ex: Jabuticabeira)
          detalhes['imagem_original'], 
          dadosExtras: detalhes
        );

        _fecharComSucesso("$nomeExibicao adicionada com sucesso! 🌱");
      } else {
        // Se não achou na API, salva sem dados extras (Modo Offline)
        await _plantaService.adicionarPlanta(nomeExibicao, null);
        _fecharComSucesso("$nomeExibicao adicionada (Modo Manual).");
      }

    } catch (e) {
      _tratarErro(e);
    }
  }

  // Quando clica em um resultado da busca manual
  Future<void> _adicionarViaBusca(Map<String, dynamic> plantaApi) async {
    setState(() {
      _isSaving = true;
      _statusMessage = 'Baixando ficha técnica...';
    });

    try {
      final detalhes = await _apiService.buscarDetalhesPorId(plantaApi['id']);
      
      await _plantaService.adicionarPlanta(
        plantaApi['nome_comum'], // Usa o nome que veio da API
        detalhes['imagem_original'], 
        dadosExtras: detalhes
      );

      _fecharComSucesso("Planta adicionada! 🌱");
    } catch (e) {
      _tratarErro(e);
    }
  }

  Future<void> _adicionarCustomizado() async {
    final nomeDigitado = _searchController.text.trim();
    if (nomeDigitado.isEmpty) return;

    setState(() {
      _isSaving = true;
      _statusMessage = 'Criando planta personalizada...';
    });

    try {
      await _plantaService.adicionarPlanta(nomeDigitado, null);
      _fecharComSucesso("Planta personalizada criada!");
    } catch (e) {
      _tratarErro(e);
    }
  }

  void _fecharComSucesso(String msg) {
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xff386641)),
    );
  }

  void _tratarErro(Object e) {
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _statusMessage = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: $e')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.90, // Modal bem alto para caber o catálogo
      child: Container(
        padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 0),
        decoration: const BoxDecoration(
          color: Color(0xff588157),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const Text(
              'O que vamos plantar hoje?',
              style: TextStyle(color: Color(0xfff2f2f2), fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // --- Input de Busca ---
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Color(0xFF3A5A40)),
              decoration: InputDecoration(
                hintText: 'Buscar planta ou escolher abaixo...',
                filled: true,
                fillColor: const Color(0xfff2f2f2),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF3A5A40)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
            
            const SizedBox(height: 15),

            // --- CONTEÚDO PRINCIPAL ---
            Expanded(
              child: _isSaving 
                  ? _buildLoadingState() // Tela de "Salvando..."
                  : _isSearching
                      ? _buildSearchResults() // Tela de Resultados da Busca
                      : _buildCatalogoView(), // Tela Padrão (Catálogo de 40 itens)
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
        const SizedBox(height: 16),
        Text(
          _statusMessage,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        )
      ],
    );
  }

  // Exibe o Catálogo Categorizado (Frutas, Horta, Flores...)
  Widget _buildCatalogoView() {
    return ListView(
      children: _catalogo.entries.map((categoria) {
        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true, // Começa aberto para ver as opções
            title: Text(
              categoria.key, // Ex: "Frutíferas 🍒"
              style: const TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold, 
                fontSize: 18
              ),
            ),
            iconColor: Colors.white,
            collapsedIconColor: Colors.white70,
            children: categoria.value.map((planta) {
              return ListTile(
                contentPadding: const EdgeInsets.only(left: 16, right: 8),
                leading: const Icon(Icons.add_circle_outline, color: Color(0xFFA7C957)),
                title: Text(
                  planta['nome']!, // Ex: "Jabuticabeira"
                  style: const TextStyle(color: Color(0xfff2f2f2)),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
                onTap: () => _selecionarDoCatalogo(planta['nome']!, planta['busca']!),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  // Exibe resultados quando o usuário digita algo
  Widget _buildSearchResults() {
    if (_isLoadingSearch) {
      return const Center(child: CircularProgressIndicator(color: Colors.white54));
    }

    final bool mostrarOpcaoCustom = _searchController.text.isNotEmpty;

    return ListView.separated(
      itemCount: _resultadosBuscaApi.length + (mostrarOpcaoCustom ? 1 : 0),
      separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
      itemBuilder: (context, index) {
        
        if (mostrarOpcaoCustom && index == 0) {
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.edit, color: Colors.white),
            ),
            title: Text(
              'Criar "${_searchController.text}" manualmente',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Caso não encontre na lista abaixo',
              style: TextStyle(color: Colors.white70),
            ),
            onTap: _adicionarCustomizado,
          );
        }

        final dataIndex = mostrarOpcaoCustom ? index - 1 : index;
        final planta = _resultadosBuscaApi[dataIndex];
        final bool temImagem = planta['imagem_url'] != null && planta['imagem_url'].toString().isNotEmpty;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white24,
            backgroundImage: temImagem ? NetworkImage(planta['imagem_url']) : null,
            child: !temImagem ? const Icon(Icons.local_florist, color: Colors.white70) : null,
          ),
          title: Text(
            planta['nome_comum'] ?? 'Desconhecida',
            style: const TextStyle(color: Color(0xfff2f2f2), fontWeight: FontWeight.w600),
          ),
          onTap: () => _adicionarViaBusca(planta),
        );
      },
    );
  }
}