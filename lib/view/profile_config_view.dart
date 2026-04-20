import 'package:flowvenue/view/crear_event_view.dart';
import 'package:flutter/material.dart';
import 'package:flowvenue/model/users_model.dart';
import 'package:flowvenue/view/solicitud_rol_view.dart';
import 'package:flowvenue/view/promocionarme_view.dart';
import 'package:flowvenue/view/buscar_artista_view.dart';
import 'package:flowvenue/services/db_services.dart';
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
  String? _artistaSpotifySeleccionat;

  @override
  void initState() {
    super.initState();
    _usuariLocal = widget.usuariActual;
    _nameController = TextEditingController(text: widget.usuariActual.username);
    // Carreguem l'artista que ja està guardat a la base de dades (si n'hi ha)
    _artistaSpotifySeleccionat = widget.usuariActual.artistaSpotify;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Funció per guardar el vincle amb Spotify permanentment
  Future<void> _vincularArtistaSpotify(String nomArtista) async {
    Usuari usuariActualitzat = Usuari(
      userId: _usuariLocal.userId,
      userIdInt: _usuariLocal.userIdInt,
      username: _usuariLocal.username,
      password: _usuariLocal.password,
      email: _usuariLocal.email,
      role: _usuariLocal.role,
      phone: _usuariLocal.phone,
      favouriteGeneres: _usuariLocal.favouriteGeneres,
      artistaSpotify: nomArtista, // Nou valor
    );

    bool ok = await DbServices().updatePerfil(usuariActualitzat);
    if (ok) {
      setState(() {
        _artistaSpotifySeleccionat = nomArtista;
        _usuariLocal = usuariActualitzat;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isServei = _usuariLocal.isServei();
    bool isArtista = _usuariLocal.isArtista();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
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
                  const SizedBox(height: 40),
                  Image.asset('assets/Logo_FlowVenue.png', height: 140),
                  const SizedBox(height: 40),
                  _buildAgendaButton(),
                  const SizedBox(height: 30),
                  _buildTextField("Usuario", _nameController, Icons.edit),
                  _buildReadOnlyField("Rol actual", _usuariLocal.role.toUpperCase()),

                  TextButton(
                    onPressed: () => _canviarRol(),
                    child: const Text("Solicitar cambio de rol",
                        style: TextStyle(color: Colors.white, decoration: TextDecoration.underline, fontSize: 13)),
                  ),

                  const SizedBox(height: 30),

                  // SECCIÓ SPOTIFY PER ARTISTES
                  if (isArtista) _buildSpotifySelector(),

                  if (isServei)
                    _buildActionBtn("+ Crear Evento", () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CrearEventView()));
                    }),

                  if (isArtista)
                    _buildActionBtn("Promocionarme", () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => PromocionarmeView(nomArtistaSpotify: _artistaSpotifySeleccionat)
                      ));
                    }),

                  const SizedBox(height: 50),
                  const Text("©2026 FlowVenue by Oriol&Jan",
                      style: TextStyle(color: Colors.white54, fontSize: 10)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpotifySelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: GestureDetector(
        onTap: () async {
          final String? nomArtista = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BuscarArtistaView())
          );
          if (nomArtista != null) {
            _vincularArtistaSpotify(nomArtista);
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: _artistaSpotifySeleccionat != null ? const Color(0xFFD988B9) : Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [if(_artistaSpotifySeleccionat != null) const BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _artistaSpotifySeleccionat ?? "Identifícate como artista (Spotify)",
                  style: TextStyle(
                      color: _artistaSpotifySeleccionat != null ? Colors.white : Colors.black45,
                      fontWeight: FontWeight.bold
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                  _artistaSpotifySeleccionat != null ? Icons.verified : Icons.search,
                  color: _artistaSpotifySeleccionat != null ? Colors.white : Colors.black54
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- MÈTODES DE SUPORT (Iguals que el teu codi original corregit) ---

  Widget _buildAgendaButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      ),
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AgendaView())),
      icon: const Icon(Icons.calendar_month, color: Color(0xFFE94E77)),
      label: const Text("VER MI AGENDA", style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _canviarRol() async {
    final String? nouRol = await Navigator.push(
      context, MaterialPageRoute(builder: (context) => solicitud_rol_view(usuariActual: _usuariLocal)),
    );
    if (nouRol != null) {
      Usuari usuariActualitzat = Usuari(
        userId: _usuariLocal.userId,
        userIdInt: _usuariLocal.userIdInt,
        username: _usuariLocal.username,
        password: _usuariLocal.password,
        email: _usuariLocal.email,
        role: nouRol,
        phone: _usuariLocal.phone,
        favouriteGeneres: _usuariLocal.favouriteGeneres,
        artistaSpotify: _usuariLocal.artistaSpotify,
      );
      if (await DbServices().updatePerfil(usuariActualitzat)) {
        setState(() => _usuariLocal = usuariActualitzat);
      }
    }
  }

  Widget _buildActionBtn(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD988B9),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: onPressed,
          child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildHeader() => Row(children: [CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context, _usuariLocal)))]);

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      TextField(
        controller: controller,
        style: const TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          filled: true, fillColor: Colors.white, suffixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
      const SizedBox(height: 15),
    ]);
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      Container(
        width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white30)),
        child: Text(value, style: const TextStyle(color: Colors.white)),
      ),
    ]);
  }
}