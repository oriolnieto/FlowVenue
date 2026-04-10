import 'package:flowvenue/view/crear_event_view.dart';
import 'package:flutter/material.dart';
import 'package:flowvenue/model/users_model.dart';
import 'package:flowvenue/view/solicitud_rol_view.dart';
import 'package:flowvenue/view/promocionarme_view.dart';
import 'package:flowvenue/view/buscar_artista_view.dart';
import 'package:flowvenue/services/db_services.dart'; // IMPORTANT: Importem la base de dades
import 'agenda_view.dart';

class PerfilConfigView extends StatefulWidget {
  final Usuari usuariActual;

  const PerfilConfigView({super.key, required this.usuariActual});

  @override
  State<PerfilConfigView> createState() => _PerfilConfigViewState();
}

class _PerfilConfigViewState extends State<PerfilConfigView> {
  late TextEditingController _nameController;



  late Usuari _usuariLocal;

  // VARIABLE PER GUARDAR L'ARTISTA DE SPOTIFY SELECCIONAT
  String? _artistaSpotifySeleccionat;

  @override
  void initState() {
    super.initState();
    // Carreguem les dades reals de l'usuari als controladors
    _usuariLocal = widget.usuariActual;
    _nameController = TextEditingController(text: widget.usuariActual.username);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Verificació de permisos segons el rol
    bool isServei = _usuariLocal.isServei();
    bool isArtista = _usuariLocal.isArtista();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        // Retorna l'usuari actualitzat si l'usuari utilitza el botó físic d'anar enrere
        Navigator.pop(context, _usuariLocal);
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/Background_App.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildProfileImage(),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => print("Canviar contrasenya"),
                    child: const Text("Actualitzar Contrasenya",
                        style: TextStyle(color: Colors.white, decoration: TextDecoration.underline)),
                  ),
                  const SizedBox(height: 20),

                  // Camps del formulari (SENSE EL TELÈFON)
                  _buildTextField("Usuario", _nameController, Icons.edit),

                  // Aquest camp mostrarà sempre el rol actualitzat a l'instant
                  _buildReadOnlyField("Rol", _usuariLocal.role.toUpperCase()),

                  const SizedBox(height: 15),

                  // Botó per sol·licitar canvi de rol
                  TextButton(
                    onPressed: () async {
                      // 1. Obrim la pantalla i esperem a veure quin rol ens retorna
                      final String? nouRol = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => solicitud_rol_view(usuariActual: _usuariLocal),
                        ),
                      );

                      // 2. Si l'usuari ha triat un nou rol (ha clicat "Sí, enviar")
                      if (nouRol != null) {
                        // Creem una còpia de l'usuari amb el ROL NOU
                        Usuari usuariActualitzat = Usuari(
                          userId: _usuariLocal.userId,
                          userIdInt: _usuariLocal.userIdInt,
                          username: _usuariLocal.username,
                          password: _usuariLocal.password,
                          email: _usuariLocal.email,
                          role: nouRol, // <-- APLIQUEM EL NOU ROL
                          phone: _usuariLocal.phone,
                          favouriteGeneres: _usuariLocal.favouriteGeneres,
                        );

                        // 3. GUARDEM ELS CANVIS A FIREBASE AL MOMENT
                        bool actualitzatDB = await DbServices().updatePerfil(usuariActualitzat);

                        if (actualitzatDB) {
                          // Si s'ha guardat bé a Firebase, actualitzem la vista
                          setState(() {
                            _usuariLocal = usuariActualitzat;
                          });

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Rol actualizado con éxito en la base de datos', style: TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.green
                              ),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error al actualizar el rol en la base de datos'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      }
                    },
                    child: const Text("Solicitar cambio de rol",
                        style: TextStyle(color: Colors.white, decoration: TextDecoration.underline, fontSize: 12)),
                  ),

                  // --- CAMP EXCLUSIU PER A ARTISTES (SPOTIFY) ---
                  if (isArtista)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Perfil Musical", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: () async {
                              final String? nomArtista = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BuscarArtistaView()),
                              );

                              if (nomArtista != null) {
                                setState(() {
                                  _artistaSpotifySeleccionat = nomArtista;
                                });
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              decoration: BoxDecoration(
                                color: _artistaSpotifySeleccionat != null ? const Color(0xFFD988B9) : Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _artistaSpotifySeleccionat ?? "Identifícate como artista (Spotify)",
                                      style: TextStyle(
                                        color: _artistaSpotifySeleccionat != null ? Colors.white : Colors.black45,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    Icons.search,
                                    color: _artistaSpotifySeleccionat != null ? Colors.white : Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // BOTONS CONDICIONALS SEGONS EL ROL
                  if (isServei)
                    _buildActionBtn("+ Crear Evento", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CrearEventView(),
                        ),
                      );
                    }),

                  if (isArtista)
                    _buildActionBtn("Promocionarme", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PromocionarmeView(),
                        ),
                      );
                    }),
                  const SizedBox(height: 40),
                  const Text("©2026 FlowVenue by Oriol&Jan",
                      style: TextStyle(color: Colors.white54, fontSize: 10)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD988B9),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: onPressed,
        child: Text(text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            // AQUESTA LÍNIA ÉS CLAU: Quan tires enrere amb la fletxa, passem l'usuari actualitzat!
            onPressed: () => Navigator.pop(context, _usuariLocal),
          ),
        ),
        Image.asset('assets/Logo_FlowVenue.png', height: 50),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildProfileImage() {
    return SizedBox(
      width: 250,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundColor: Color(0xFFF1B1CB),
            child: Icon(Icons.person, size: 70, color: Colors.black),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: _buildFloatingButton(Icons.calendar_month, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AgendaView()),
              );
            }),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: _buildFloatingButton(Icons.edit_note, () {
              print("Editant perfil...");
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 22,
        child: IconButton(
          icon: Icon(icon, size: 22, color: Colors.black),
          onPressed: onTap,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            style: const TextStyle(color: Color(0xFFE94E77)),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              suffixIcon: Icon(icon, color: Colors.black),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(25)),
            child: Text(value, style: const TextStyle(color: Colors.black45)),
          ),
        ],
      ),
    );
  }
}