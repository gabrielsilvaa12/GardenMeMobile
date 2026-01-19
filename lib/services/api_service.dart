import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ MANTENHA SUA CHAVE AQUI
  final String _apiKey = 'sk-hUnU696d58d27700514405'; 
  final String _baseUrl = 'https://perenual.com/api';

  // --- CATÁLOGO DE 40 PLANTAS (CURADORIA GARDENME) ---
  // Mapeamos o nome em PT para o termo de busca exato (Inglês ou Científico)
  // para garantir que a API encontre a planta correta.
  final Map<String, List<Map<String, String>>> _catalogoBrasileiro = {
    'Frutíferas 🍒': [
      {'nome': 'Jabuticabeira', 'busca': 'Plinia cauliflora'}, // Científico (Nativa)
      {'nome': 'Limoeiro', 'busca': 'Lemon'},
      {'nome': 'Pitangueira', 'busca': 'Eugenia uniflora'}, // Científico (Nativa)
      {'nome': 'Romãzeira', 'busca': 'Pomegranate'},
      {'nome': 'Aceroleira', 'busca': 'Malpighia emarginata'},
      {'nome': 'Morangueiro', 'busca': 'Strawberry'},
      {'nome': 'Amoreira', 'busca': 'Blackberry'},
      {'nome': 'Goiabeira', 'busca': 'Guava'},
      {'nome': 'Laranjinha Kinkan', 'busca': 'Kumquat'},
      {'nome': 'Maracujazeiro', 'busca': 'Passion Fruit'},
    ],
    'Horta & Temperos 🥗': [
      {'nome': 'Alface', 'busca': 'Lettuce'},
      {'nome': 'Cenoura', 'busca': 'Carrot'},
      {'nome': 'Tomate Cereja', 'busca': 'Cherry Tomato'},
      {'nome': 'Cebolinha', 'busca': 'Green Onion'},
      {'nome': 'Salsinha', 'busca': 'Parsley'},
      {'nome': 'Hortelã', 'busca': 'Mint'},
      {'nome': 'Manjericão', 'busca': 'Basil'},
      {'nome': 'Rúcula', 'busca': 'Arugula'},
      {'nome': 'Couve Manteiga', 'busca': 'Kale'},
      {'nome': 'Pimentão', 'busca': 'Bell Pepper'},
    ],
    'Flores & Ornamentais 🌺': [
      {'nome': 'Orquídea', 'busca': 'Phalaenopsis'},
      {'nome': 'Violeta', 'busca': 'African Violet'},
      {'nome': 'Rosa', 'busca': 'Rose'},
      {'nome': 'Girassol', 'busca': 'Sunflower'},
      {'nome': 'Antúrio', 'busca': 'Anthurium'},
      {'nome': 'Lírio da Paz', 'busca': 'Peace Lily'},
      {'nome': 'Kalanchoe', 'busca': 'Kalanchoe'},
      {'nome': 'Begônia', 'busca': 'Begonia'},
      {'nome': 'Azaleia', 'busca': 'Azalea'},
      {'nome': 'Hibisco', 'busca': 'Hibiscus'},
    ],
    'Cactos & Suculentas 🌵': [
      {'nome': 'Espada de São Jorge', 'busca': 'Snake Plant'},
      {'nome': 'Zamioculca', 'busca': 'ZZ Plant'},
      {'nome': 'Babosa (Aloe)', 'busca': 'Aloe Vera'},
      {'nome': 'Echeveria', 'busca': 'Echeveria'},
      {'nome': 'Mandacaru', 'busca': 'Cereus jamacaru'}, // Científico (Nativa)
      {'nome': 'Rabo-de-Burro', 'busca': 'Burro\'s Tail'},
      {'nome': 'Colar-de-Pérolas', 'busca': 'String of Pearls'},
      {'nome': 'Flor-de-Maio', 'busca': 'Christmas Cactus'},
      {'nome': 'Orelha-de-Mickey', 'busca': 'Bunny Ear Cactus'},
      {'nome': 'Dedinho-de-Moça', 'busca': 'Sedum morganianum'},
    ],
  };

  // Retorna o catálogo organizado para a tela de adicionar
  Map<String, List<Map<String, String>>> getCatalogoCompleto() {
    return _catalogoBrasileiro;
  }

  // Busca na API usando o termo mapeado (ex: Clica em "Jabuticaba" -> Busca "Plinia cauliflora")
  Future<List<Map<String, dynamic>>> pesquisarPlantas(String query) async {
    // 1. Tenta traduzir o termo digitado
    String termoBusca = _traduzirNomeParaBusca(query);
    
    final uri = Uri.parse('$_baseUrl/species-list?key=$_apiKey&q=$termoBusca');
    
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List lista = data['data'];
        
        return lista.map((item) {
          // Tenta pegar a imagem, se não tiver, manda string vazia
          String thumb = item['default_image']?['thumbnail'] ?? '';
          
          return {
            'id': item['id'],
            'nome_comum': item['common_name'], // Nome em inglês da API
            'nome_cientifico': item['scientific_name'] != null ? item['scientific_name'][0] : '',
            'imagem_url': thumb,
          };
        }).toList();
      }
    } catch (e) {
      print("Erro na busca: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>> buscarDetalhesPorId(int id) async {
    final uri = Uri.parse('$_baseUrl/species/details/$id?key=$_apiKey');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final details = json.decode(response.body);
      
      return {
        'nome_oficial': details['common_name'],
        'imagem_original': details['default_image']?['original_url'], 
        'estacao_ideal': _traduzirEstacao(details['flowering_season']),
        'tipo_terra': _traduzirSolo(details['soil']),
        'intervalo_rega': _calcularIntervaloRega(details['watering']),
        'rega_dica': _gerarDicaRega(details['watering']), 
        'dica_fertilizante': _gerarDicaFertilizante(details),
      };
    }
    return {};
  }

  // --- TRADUTORES E REGRAS ---

  // Tradutor Reverso: Se o usuário DIGITAR na busca, tentamos adivinhar o termo em inglês
  String _traduzirNomeParaBusca(String nomePt) {
    final termo = nomePt.toLowerCase().trim();
    
    // Frutíferas
    if (termo.contains('jabuticaba')) return 'Plinia cauliflora';
    if (termo.contains('pitanga')) return 'Eugenia uniflora';
    if (termo.contains('limao') || termo.contains('limão')) return 'Lemon';
    if (termo.contains('acerola')) return 'Malpighia emarginata';
    if (termo.contains('goiaba')) return 'Guava';
    if (termo.contains('maracuja') || termo.contains('maracujá')) return 'Passion Fruit';
    
    // Horta
    if (termo.contains('alface')) return 'Lettuce';
    if (termo.contains('couve')) return 'Kale';
    if (termo.contains('manjericao') || termo.contains('manjericão')) return 'Basil';
    
    // Ornamentais
    if (termo.contains('orquidea') || termo.contains('orquídea')) return 'Phalaenopsis';
    if (termo.contains('espada')) return 'Snake Plant';
    if (termo.contains('zamioculca')) return 'ZZ Plant';
    if (termo.contains('mandacaru')) return 'Cereus jamacaru';

    // Se não achar, tenta buscar pelo que a pessoa digitou mesmo
    return nomePt;
  }

  String _traduzirEstacao(dynamic season) {
    if (season == null) return "Ano todo";
    String s = season.toString().toLowerCase();
    if (s.contains('spring')) return "Primavera";
    if (s.contains('summer')) return "Verão";
    if (s.contains('winter')) return "Inverno";
    if (s.contains('autumn') || s.contains('fall')) return "Outono";
    return "Ano todo";
  }

  String _traduzirSolo(List<dynamic>? soils) {
    if (soils == null || soils.isEmpty) return "Terra Vegetal";
    String type = soils[0].toString().toLowerCase();
    if (type.contains('sand')) return "Terra com Areia (Drenável)";
    if (type.contains('clay')) return "Terra Argilosa (Firme)";
    return "Terra Vegetal Preta";
  }

  int _calcularIntervaloRega(String? watering) {
    switch (watering) {
      case 'Frequent': return 2;
      case 'Average': return 5;
      case 'Minimum': return 10;
      case 'None': return 30;
      default: return 7;
    }
  }

  String _gerarDicaRega(String? watering) {
    switch (watering) {
      case 'Frequent': 
        return "A terra deve ficar BEM ÚMIDA (quase encharcada).";
      case 'Average': 
        return "A terra deve ficar LEVEMENTE ÚMIDA (fresca).";
      case 'Minimum': 
        return "A terra deve ficar SECA antes de regar.";
      case 'None':
        return "A terra deve ficar MUITO SECA (esturricada).";
      default: 
        return "Terra úmida, sem encharcar.";
    }
  }

  String _gerarDicaFertilizante(Map<String, dynamic> details) {
    bool flowers = details['flowers'] == true;
    String type = (details['type'] ?? '').toString().toLowerCase();

    if (flowers) {
      return "Farinha de Ossos (Rico em Fósforo)";
    } else if (type.contains('succulent') || type.contains('cactus')) {
       return "Casca de Ovo ou Cálcio";
    } else {
      return "Húmus de Minhoca (Nitrogênio)";
    }
  }
}