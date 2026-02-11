import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

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