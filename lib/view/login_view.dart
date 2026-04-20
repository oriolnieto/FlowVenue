import 'package:flutter/material.dart';
import 'package:flowvenue/view/partyFeed_view.dart';
import 'package:flowvenue/model/party_model.dart';
import 'package:flowvenue/services/db_services.dart';

class LoginView extends StatefulWidget {
  final Festa? festa;
  const LoginView({super.key, this.festa});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DbServices _dbServices = DbServices();

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Evita que el teclat "empenyi" el fons de pantalla i el deformi
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Background_App.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // --- BOTÓ TORNAR ENRERE ---
            Positioned(
              top: 50,
              left: 20,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // --- CONTINGUT PRINCIPAL AMB SCROLL PER EVITAR OVERFLOW ---
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo ajustat per no saturar la pantalla
                      Image.asset(
                        'assets/Logo_FlowVenue.png',
                        height: 220,
                        width: 220,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 40),

                      // Camp d'Usuari
                      TextField(
                        controller: _userController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Usuario',
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.person, color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Camp de Contrasenya
                      TextField(
                        obscureText: true,
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Contraseña',
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.lock, color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Botó d'Acció
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () async {
                            String username = _userController.text.trim();
                            String password = _passwordController.text.trim();

                            if (username.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Escriu usuari i contrasenya')),
                              );
                              return;
                            }

                            // Intentem fer login (o registre automàtic segons la teva DB)
                            final usuari = await _dbServices.login(username, password);

                            if (usuari != null) {
                              if (!mounted) return;

                              if (widget.festa != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => partyFeed_view(
                                      idFesta: widget.festa!.partyId,
                                      usuari: usuari,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.pop(context, usuari);
                              }
                            } else {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Credencials incorrectes o error de permisos')),
                              );
                            }
                          },
                          child: const Text(
                            'Acceder / Registrarse',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),

                      // Espai addicional per si el teclat és molt alt en web/mòbil
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}