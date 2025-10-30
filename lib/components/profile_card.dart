import 'package:flutter/material.dart';

class ProfileCard extends StatefulWidget {
  const ProfileCard({super.key});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  final _nome = TextEditingController();
  final _sobrenome = TextEditingController();
  final _email = TextEditingController();
  final _telefone = TextEditingController();

  void dispose() {
    _nome.dispose();
    _sobrenome.dispose();
    _email.dispose();
    _telefone.dispose();
    super.dispose();
  }

  Widget _campo(
    String label,
    TextEditingController controller, {
    bool opcional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          opcional ? '$label (opcional)' : '$label *',
          style: TextStyle(
            color: Color(0xFFf2f2f2),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  void _salvar() {
    if (_nome.text.isEmpty || _email.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, preencha os campos obrigatórios.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Perfil salvo com sucesso!'),
        backgroundColor: Color(0xff6a994e),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xff588157),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: Color(0xFFa7c957).withOpacity(0.5),
            child: CircleAvatar(
              radius: 48,
              backgroundImage: AssetImage('assets/images/moranguito.png'),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Joselito',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFf2f2f2),
            ),
          ),
          SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFa7c957),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Text(
                          'Mago do Jardim',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2d2f2d),
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.star, color: Color(0xff2d2f2d), size: 18),
                      ],
                    ),
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF3A5A40),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: const LinearProgressIndicator(
                    value: 0.6,
                    backgroundColor: Colors.white54,
                    valueColor: AlwaysStoppedAnimation(Color(0xFF3A5A40)),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Meu progresso',
                  style: TextStyle(color: Color(0xfff2f2f2), fontSize: 16),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          const Align(
            alignment: Alignment.center,
            child: Text(
              'Perfil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xfff2f2f2),
              ),
            ),
          ),
          SizedBox(height: 16),
          _campo('Nome', _nome),
          _campo('Sobrenome', _sobrenome, opcional: true),
          _campo('E-mail', _email),
          _campo('Telefone', _telefone, opcional: true),

          SizedBox(height: 16),

          ElevatedButton(
            onPressed: _salvar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA7C957),
              foregroundColor: const Color(0xFF3A5A40),
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Salvar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
