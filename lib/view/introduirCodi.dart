import 'package:flowvenue/view/buscador_festa_view.dart';
import 'package:flowvenue/view/partyFeed_view.dart';
import 'package:flowvenue/view/profile_config_view.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:flowvenue/view/login_view.dart';
import 'package:flowvenue/services/db_services.dart';
import 'package:flowvenue/model/users_model.dart';

class introduirCodi extends StatefulWidget {
  const introduirCodi({super.key});

  @override
  State<introduirCodi> createState() => _IntroduirCodiState();
}

class _IntroduirCodiState extends State<introduirCodi> {
  final TextEditingController codiController = TextEditingController();
  Usuari? _currentUser;

  @override
  void dispose() {
    codiController.dispose();
    super.dispose();
  }

  // Funció per netejar l'estat en tornar
  void _resetScreen() {
    setState(() {
      codiController.clear();
    });
    FocusScope.of(context).unfocus(); // Treu el focus del teclat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Background_App.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // --- BOTÓ PERFIL ---
          Positioned(
            top: 50,
            left: 20,
            child: PopupMenuButton<String>(
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              onSelected: (value) async {
                if (value == 'login') {
                  final Usuari? usuariLoguejat = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView()),
                  );
                  if (usuariLoguejat != null) {
                    setState(() => _currentUser = usuariLoguejat);
                  }
                } else if (value == 'config') {
                  final Usuari? usuariActualitzat = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PerfilConfigView(usuariActual: _currentUser!),
                    ),
                  );
                  if (usuariActualitzat != null) {
                    setState(() => _currentUser = usuariActualitzat);
                  }
                } else if (value == 'logout') {
                  setState(() => _currentUser = null);
                }
              },
              itemBuilder: (BuildContext context) {
                if (_currentUser == null) {
                  return [
                    const PopupMenuItem(
                      value: 'login',
                      child: Row(children: [Icon(Icons.login), SizedBox(width: 10), Text('Entrar')]),
                    ),
                  ];
                } else {
                  return [
                    const PopupMenuItem(
                      value: 'config',
                      child: Row(children: [Icon(Icons.settings), SizedBox(width: 10), Text('Ajustes')]),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 10), Text('Salir')]),
                    ),
                  ];
                }
              },
              child: _buildCircleIconButton(
                icon: Icons.person,
                color: _currentUser != null ? const Color(0xFFE94E77) : Colors.black,
              ),
            ),
          ),

          // --- BOTÓ BUSCADOR ---
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => buscador_festa_view(usuariActual: _currentUser)),
              ),
              child: _buildCircleIconButton(icon: Icons.search),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/Logo_FlowVenue.png', height: 350, width: 350),
                    const Text('Introduce el Código:', style: TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 15),

                    Pinput(
                      length: 5,
                      controller: codiController,
                      defaultPinTheme: PinTheme(
                        width: 50, height: 50,
                        textStyle: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                        decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 2, color: Colors.white))),
                      ),
                      onCompleted: (pin) async {
                        // 1. Tanquem teclat abans de res
                        FocusScope.of(context).unfocus();

                        final festa = await DbServices().getFestaByAccessCode(int.parse(pin));

                        if (festa != null) {
                          if (_currentUser != null) {
                            // Si anem a la festa, fem push i netegem en tornar
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => partyFeed_view(idFesta: festa.partyId, usuari: _currentUser!)),
                            ).then((_) => _resetScreen()); 
                          } else {
                            // Si anem al login, el mateix
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginView(festa: festa)),
                            ).then((_) => _resetScreen());
                          }
                        } else {
                          codiController.clear(); // Codi erroni, netegem
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Código inválido')),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 250),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar per no repetir codi dels botons rodons
  Widget _buildCircleIconButton({required IconData icon, Color color = Colors.black}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}