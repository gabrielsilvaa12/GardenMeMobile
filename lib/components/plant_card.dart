import 'dart:async'; 
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gardenme/models/planta.dart';
import 'package:gardenme/pages/alarms_page.dart';
import 'package:gardenme/pages/my_plant.dart';
import 'package:gardenme/services/planta_service.dart';
import 'package:gardenme/services/theme_service.dart';

// Imports para o compartilhamento
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gardenme/components/plant_share_card.dart';

class PlantCard extends StatefulWidget {
  final Planta planta;

  const PlantCard({super.key, required this.planta});

  @override
  State<PlantCard> createState() => _PlantCardState();
}

class _PlantCardState extends State<PlantCard> {
  final PlantaService _plantaService = PlantaService();
  final ScreenshotController _screenshotController = ScreenshotController();
  
  // Estado local - Inicia Laranja por padrão
  Color _corBorda = Colors.orange; 
  
  // Cache dos alarmes e Streams
  List<Map<String, dynamic>> _alarmesCache = [];
  StreamSubscription? _alarmesSubscription;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 1. Inicia a escuta dos alarmes em tempo real
    _iniciarStreamAlarmes();
    
    // 2. Timer rápido de 1 segundo para garantir a mudança "em tempo real"
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calcularCorBorda();
    });
    
    // 3. Calcula imediatamente
    _calcularCorBorda();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _alarmesSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(PlantCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se a planta mudar (ex: regada, ou ID mudou), reinicia a lógica
    if (oldWidget.planta.rega != widget.planta.rega || oldWidget.planta.id != widget.planta.id) {
      if (oldWidget.planta.id != widget.planta.id) {
        _iniciarStreamAlarmes();
      } else {
        _calcularCorBorda();
      }
    }
  }

  /// Escuta os alarmes dessa planta no Firebase em tempo real
  void _iniciarStreamAlarmes() {
    _alarmesSubscription?.cancel(); 

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    _alarmesSubscription = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userId)
        .collection('alarmes')
        .where('planta_id', isEqualTo: widget.planta.id)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _alarmesCache = snapshot.docs.map((doc) => doc.data()).toList();
        });
        _calcularCorBorda();
      }
    }, onError: (e) {
      print("Erro no stream de alarmes: $e");
    });
  }

  /// Lógica PURA para definir a cor baseada no cache e na hora atual
  void _calcularCorBorda() {
    if (!mounted) return;

    // Regra 1: Se já está regada (Verde), prioridade máxima
    if (widget.planta.rega) {
      if (_corBorda != const Color(0xFFAFF695)) {
        setState(() {
          _corBorda = const Color(0xFFAFF695); // Verde
        });
      }
      return;
    }

    // Regra 2: Se não tem alarmes, é Laranja
    if (_alarmesCache.isEmpty) {
      if (_corBorda != Colors.orange) {
        setState(() {
          _corBorda = Colors.orange;
        });
      }
      return;
    }

    // Regra 3: Verifica atraso com tolerância de 1 minuto
    bool estaAtrasada = false;
    final agora = DateTime.now();
    
    // Se nunca foi regada, usamos uma data antiga como referência
    final ultimaRega = widget.planta.dataUltimaRega ?? DateTime(2000);

    // Validação de segurança para a data de criação
    final dataCriacao = widget.planta.dataCriacao ?? DateTime(2000);

    for (var data in _alarmesCache) {
      final diasSemana = List<int>.from(data['dias_semana'] ?? []); 
      final hora = data['hora'] as int;
      final minuto = data['minuto'] as int;
      final ativo = data['ativo'] ?? true;

      if (!ativo) continue;

      for (int diaSemana in diasSemana) {
        DateTime ocorrenciaBase = _obterUltimaOcorrencia(diaSemana, hora, minuto, agora);
        
        // Tolerância de 1 minuto
        DateTime limiteTolerancia = ocorrenciaBase.add(const Duration(minutes: 1));

        // Se JÁ PASSOU da tolerância...
        if (agora.isAfter(limiteTolerancia)) {
          // ...E essa ocorrência foi DEPOIS da última vez que eu reguei
          // ...E essa ocorrência foi DEPOIS que a planta foi criada!
          if (ocorrenciaBase.isAfter(ultimaRega) && ocorrenciaBase.isAfter(dataCriacao)) {
            estaAtrasada = true;
            break; 
          }
        }
      }
      if (estaAtrasada) break;
    }

    // MUDANÇA AQUI: De Colors.red para Colors.redAccent
    final novaCor = estaAtrasada ? Colors.redAccent : Colors.orange;

    if (_corBorda != novaCor) {
      setState(() {
        _corBorda = novaCor;
      });
    }
  }

  /// Helper: Retorna a data/hora exata que esse alarme deveria ter tocado (hoje ou passado)
  DateTime _obterUltimaOcorrencia(int diaAlvo, int hora, int minuto, DateTime agora) {
    DateTime dataTeste = DateTime(agora.year, agora.month, agora.day, hora, minuto);

    if (agora.weekday == diaAlvo) {
      // É hoje.
      if (agora.isAfter(dataTeste) || agora.isAtSameMomentAs(dataTeste)) {
        return dataTeste; // Foi hoje
      } else {
        return dataTeste.subtract(const Duration(days: 7)); // Foi semana passada
      }
    } else {
      // Não é hoje. Calcula a data passada correta.
      int diff = (agora.weekday - diaAlvo) % 7;
      if (diff < 0) diff += 7;
      return dataTeste.subtract(Duration(days: diff));
    }
  }

  Future<void> _toggleRega() async {
    if (widget.planta.rega) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Você já cuidou desta planta hoje! 🌱',
            style: TextStyle(color: Color(0xFF344e41), fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await _plantaService.atualizarStatus(
      widget.planta.id, 
      rega: true,
    );
    
    // Feedback visual imediato forçado
    if (mounted) {
       setState(() {
         _corBorda = const Color(0xFFAFF695);
       });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Planta regada com amor! 💧 +10 XP',
            style: TextStyle(color: Color(0xFF344e41), fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // --- MÉTODOS AUXILIARES ---

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
                      planta: widget.planta,
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
          text: 'Veja minha ${widget.planta.nome} no GardenMe! 🌿',
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

  Widget _buildActionButton({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback function,
  }) {
    return InkWell(
      onTap: function,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(right: 8.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: iconColor),
      ),
    );
  }

  ImageProvider _getImagemProvider() {
    final path = widget.planta.imagemUrl;
    if (path != null && path.isNotEmpty) {
      try {
        if (path.startsWith('http')) return NetworkImage(path);
        return FileImage(File(path));
      } catch (_) {}
    }
    return const AssetImage('assets/images/garden.png');
  }

  @override
  Widget build(BuildContext context) {
    bool statusRega = widget.planta.rega;

    final isDark = ThemeService.instance.currentTheme == ThemeOption.escuro;
    final cardColor = isDark ? const Color(0xFF588157) : const Color(0xFF588157);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: _corBorda,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: _getImagemProvider(),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.planta.nome,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xfff2f2f2),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      function: _toggleRega,
                      icon: Icons.water_drop_outlined,
                      backgroundColor: statusRega
                          ? const Color(0xFF81D4FA)
                          : const Color(0xFF81D4FA).withOpacity(0.5),
                      iconColor: const Color(0xfff2f2f2),
                    ),
                    _buildActionButton(
                      function: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AlarmsPage(
                              plantName: widget.planta.nome,
                              plantaId: widget.planta.id,
                            ),
                          ),
                        );
                      },
                      icon: Icons.notifications_none_outlined,
                      backgroundColor: const Color.fromARGB(255, 30, 56, 35).withOpacity(0.4),
                      iconColor: const Color(0xfff2f2f2),
                    ),
                    _buildActionButton(
                      function: _compartilharPlanta,
                      icon: Icons.share_outlined,
                      backgroundColor: const Color(0xFFE0E0E0),
                      iconColor: Colors.black87,
                    ),
                    _buildActionButton(
                      function: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MinhaPlantaPage(planta: widget.planta),
                          ),
                        );
                      },
                      icon: Icons.add,
                      backgroundColor: const Color(0xFFE0E0E0),
                      iconColor: Colors.black87,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}