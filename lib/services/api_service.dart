import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _apiKey = 'sk-hUnU696d58d27700514405'; 
  final String _baseUrl = 'https://perenual.com/api';

  // --- CATÁLOGO DE 40 PLANTAS (CURADORIA GARDENME 2.0) ---
  final Map<String, List<Map<String, String>>> _catalogoBrasileiro = {
    'Frutíferas para Vasos 🍓': [
      {'nome': 'Morango', 'busca': 'Strawberry'},
      {'nome': 'Amora-anã', 'busca': 'Blackberry'},
      {'nome': 'Pitanga-anã', 'busca': 'Eugenia uniflora'}, 
      {'nome': 'Acerola-anã', 'busca': 'Malpighia emarginata'},
      {'nome': 'Jabuticaba-anã', 'busca': 'Plinia cauliflora'},
      {'nome': 'Romã-anã', 'busca': 'Pomegranate'},
      {'nome': 'Limoeiro-anão', 'busca': 'Lemon'},
      {'nome': 'Tangerineira-anã', 'busca': 'Tangerine'},
      {'nome': 'Goiaba-anã', 'busca': 'Guava'},
      {'nome': 'Framboesa', 'busca': 'Raspberry'},
    ],
    'Vegetais & Hortaliças 🥬': [
      {'nome': 'Alface', 'busca': 'Lettuce'},
      {'nome': 'Rúcula', 'busca': 'Arugula'},
      {'nome': 'Espinafre', 'busca': 'Spinach'},
      {'nome': 'Cebolinha', 'busca': 'Green Onion'}, 
      {'nome': 'Salsinha', 'busca': 'Parsley'},
      {'nome': 'Coentro', 'busca': 'Cilantro'},
      {'nome': 'Manjericão', 'busca': 'Basil'},
      {'nome': 'Tomate-cereja', 'busca': 'Cherry Tomato'},
      {'nome': 'Pimentão', 'busca': 'Bell Pepper'},
      {'nome': 'Pimenta', 'busca': 'Chili Pepper'},
    ],
    'Flores & Ornamentais 🌸': [
      {'nome': 'Petúnia', 'busca': 'Petunia'},
      {'nome': 'Begônia', 'busca': 'Begonia'},
      {'nome': 'Violeta-africana', 'busca': 'African Violet'},
      {'nome': 'Gérbera', 'busca': 'Gerbera'},
      {'nome': 'Impatiens (Beijo)', 'busca': 'Impatiens'},
      {'nome': 'Cravina', 'busca': 'Dianthus'},
      {'nome': 'Boca-de-leão', 'busca': 'Snapdragon'},
      {'nome': 'Kalanchoê', 'busca': 'Kalanchoe'},
      {'nome': 'Amor-perfeito', 'busca': 'Pansy'},
      {'nome': 'Samambaia', 'busca': 'Fern'},
    ],
    'Cactos & Suculentas 🌵': [
      {'nome': 'Mandacaru-mini', 'busca': 'Cereus jamacaru'},
      {'nome': 'Coroa-de-frade', 'busca': 'Melocactus'},
      {'nome': 'Orelha-de-mickey', 'busca': 'Opuntia microdasys'},
      {'nome': 'Cacto-bola', 'busca': 'Echinocactus'},
      {'nome': 'Rosa-de-pedra', 'busca': 'Echeveria'},
      {'nome': 'Planta-jade', 'busca': 'Jade Plant'},
      {'nome': 'Haworthia', 'busca': 'Haworthia'},
      {'nome': 'Aloe Vera (Babosa)', 'busca': 'Aloe Vera'},
      {'nome': 'Sedum', 'busca': 'Sedum'},
      {'nome': 'Colar-de-pérolas', 'busca': 'String of Pearls'},
    ],
  };

  Map<String, List<Map<String, String>>> getCatalogoCompleto() {
    return _catalogoBrasileiro;
  }

  Future<List<Map<String, dynamic>>> pesquisarPlantas(String query) async {
    // Usa o termo direto para buscar na API
    final uri = Uri.parse('$_baseUrl/species-list?key=$_apiKey&q=$query');
    
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List lista = data['data'];
        
        return lista.map((item) {
          String thumb = item['default_image']?['thumbnail'] ?? '';
          return {
            'id': item['id'],
            'nome_comum': item['common_name'], 
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
        return "Mantenha a terra úmida.";
      case 'Average': 
        return "Regue quando o topo da terra secar.";
      case 'Minimum': 
        return "Deixe a terra secar bem antes de regar.";
      case 'None':
        return "Regue raramente (Cactos/Suculentas).";
      default: 
        return "Terra úmida, sem encharcar.";
    }
  }

  String _gerarDicaFertilizante(Map<String, dynamic> details) {
    bool flowers = details['flowers'] == true;
    String type = (details['type'] ?? '').toString().toLowerCase();

    if (flowers) {
      return "Rico em Fósforo (ex: NPK 4-14-8)";
    } else if (type.contains('succulent') || type.contains('cactus')) {
       return "Específico para Cactos ou Casca de Ovo";
    } else {
      return "Rico em Nitrogênio ou Húmus de Minhoca";
    }
  }
}