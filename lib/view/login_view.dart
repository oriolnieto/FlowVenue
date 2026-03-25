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
  Widget build(BuildContext context) {
    return Scaffold(
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
              onPressed: () {
                // Tanca la pantalla actual i torna a introduirCodi
                Navigator.pop(context);
              },
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Image.asset('assets/Logo_FlowVenue.png', height: 300, width: 300,),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  TextField(
                    controller: _userController,
                    decoration: InputDecoration(
                      hintText: 'Usuario',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    obscureText: true,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

                        // Intentem fer login (o registre si és nou)
                        final usuari = await _dbServices.login(username, password);

                        if (usuari != null) {
                          if (!mounted) return;

                          // Si hem entrat des del codi de festa: Anem a la festa
                          if (widget.festa != null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => partyFeed_view(idFesta: widget.festa!.partyId)),
                            );
                          } else {
                            // Si hem entrat des del menú de perfil: Tornem enrere i passem l'usuari
                            Navigator.pop(context, usuari);
                          }
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Contrasenya incorrecta')),
                          );
                        }
                      },
                      child: const Text('Acceder / Registrarse'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
          ],
        ),
      ),
    );
  }
}