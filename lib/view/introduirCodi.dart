import 'package:flowvenue/view/buscador_festa_view.dart';
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
  // VARIABLE D'ESTAT PER GUARDAR LA SESSIÓ OBERTA
  Usuari? _currentUser;


  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    codiController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill( // Emplenar amb l'imatge tot el fons
            child: Image.asset(
              'assets/Background_App.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: PopupMenuButton<String>(
            offset: const Offset(0, 50), // Que s'obri per sota del botó
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onSelected: (value) async {
              if (value == 'login') {
                // Obre el LoginView sense passar-li cap festa (mode inici de sessió general)
                final Usuari? usuariLoguejat = await Navigator.push(
                    context,
                      MaterialPageRoute(builder: (context) => const LoginView()),
                      );

                          // Si el login ha anat bé, guardem la sessió i actualitzem la vista
                          if (usuariLoguejat != null) {
                          setState(() {
                          _currentUser = usuariLoguejat;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('¡Bienvenido, ${_currentUser!.username}!'), backgroundColor: Colors.green),
                          );
                          }

                      } else if (value == 'config') {
                      // Entrar a la configuració amb l'usuari real
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => PerfilConfigView(usuariActual: _currentUser!),
                      ),
                      );
                      } else if (value == 'logout') {
                      // Tancar la sessió
                      setState(() {
                      _currentUser = null;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sesión cerrada correctamente')),
                      );
                      }
                      },


              // OPCIONS DEL MENÚ SEGONS SI HI HA SESSIÓ O NO
              itemBuilder: (BuildContext context) {
                if (_currentUser == null) {
                  return [
                    const PopupMenuItem(
                      value: 'login',
                      child: Row(
                        children: [
                          Icon(Icons.login, color: Colors.black),
                          SizedBox(width: 10),
                          Text('Registrarse / Iniciar sesión'),
                        ],
                      ),
                    ),
                  ];
                } else {
                  return [
                    const PopupMenuItem(
                      value: 'config',
                      child: Row(
                        children: [
                          Icon(Icons.settings, color: Colors.black),
                          SizedBox(width: 10),
                          Text('Configuración'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 10),
                          Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ];
                }
              },
              // L'ASPECTE VISUAL DEL BOTÓ
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Icon(
                  Icons.person,
                  // Pintem la icona diferent si estem loguejats
                  color: _currentUser != null ? const Color(0xFFE94E77) : Colors.black,
                  size: 24,
                ),
              ),
            ),
          ),

          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const buscador_festa_view()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.search,
                  color: Colors.black, // Icono de lupa negra
                  size: 24,
                ),
              ),
            ),
          ),



          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // Logotip
                    Image.asset(
                      'assets/Logo_FlowVenue.png',
                      height: 350,
                      width: 350,
                    ),

                    Text('Introduce el Código:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        )
                    ),

                    const SizedBox(height: 15),

                    // Input Codi
                    Pinput(
                      length: 5,
                      controller: codiController,
                      defaultPinTheme: PinTheme(
                        width: 50,
                        height: 50,
                        textStyle: const TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 2, color: Colors.white),
                          ),
                        ),
                      ),
                      onCompleted: (pin) async {
                        final festa = await DbServices().getFestaByAccessCode(int.parse(pin));

                        if (festa != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginView(festa: festa)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Codi invàlid o festa inactiva!')),
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
}