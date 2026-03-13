import 'package:flowvenue/view/buscador_festa_view.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:flowvenue/view/login_view.dart';
import 'package:flowvenue/services/db_services.dart';
import 'package:flowvenue/model/party_model.dart';

class introduirCodi extends StatefulWidget {
  const introduirCodi({super.key});


  @override
  State<introduirCodi> createState() => _IntroduirCodiState();
}

class _IntroduirCodiState extends State<introduirCodi> {
  final TextEditingController codiController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
            child: GestureDetector(
              onTap: () {
                // Aquí aniria la navegació a la teva vista de configuració de perfil
                /* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PerfilConfigView()),
                ); */

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
                  Icons.person,
                  color: Colors.black,
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
                            const SnackBar(content: Text('Codi invàlid o festa inactiva')),
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