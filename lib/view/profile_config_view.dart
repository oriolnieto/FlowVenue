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
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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

                  // --- LOGO GRAN ---
                  const SizedBox(height: 40),
                  Image.asset('assets/Logo_FlowVenue.png', height: 140),
                  const SizedBox(height: 40),

                  // BOTÓ RÀPID AGENDA
                  _buildAgendaButton(),
                  const SizedBox(height: 30),

                  // Camps del formulari
                  _buildTextField("Usuario", _nameController, Icons.edit),
                  _buildReadOnlyField("Rol actual", _usuariLocal.role.toUpperCase()),

                  // Sol·licitud de canvi de rol
                  TextButton(
                    onPressed: () => _canviarRol(),
                    child: const Text("Solicitar cambio de rol",
                        style: TextStyle(color: Colors.white, decoration: TextDecoration.underline, fontSize: 13)),
                  ),

                  const SizedBox(height: 30),

                  // --- CAMP EXCLUSIU PER A ARTISTES ---
                  if (isArtista) _buildSpotifySelector(),

                  // BOTONS D'ACCIÓ SEGONS EL ROL
                  if (isServei)
                    _buildActionBtn("+ Crear Evento", () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CrearEventView()));
                    }),

                  if (isArtista)
                    _buildActionBtn("Promocionarme", () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PromocionarmeView()));
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

  // --- BOTÓ DE L'AGENDA ---
  Widget _buildAgendaButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        elevation: 4,
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AgendaView()));
      },
      icon: const Icon(Icons.calendar_month, color: Color(0xFFE94E77)),
      label: const Text("VER MI AGENDA", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
    );
  }

  // --- LOGICA DE CAMBI DE ROL ---
  Future<void> _canviarRol() async {
    final String? nouRol = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => solicitud_rol_view(usuariActual: _usuariLocal)),
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
      );

      bool actualitzatDB = await DbServices().updatePerfil(usuariActualitzat);
      if (actualitzatDB) {
        setState(() => _usuariLocal = usuariActualitzat);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rol actualizado correctamente')));
        }
      }
    }
  }

  Widget _buildSpotifySelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: GestureDetector(
        onTap: () async {
          final String? nomArtista = await Navigator.push(context, MaterialPageRoute(builder: (context) => const BuscarArtistaView()));
          if (nomArtista != null) setState(() => _artistaSpotifySeleccionat = nomArtista);
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
              Text(_artistaSpotifySeleccionat ?? "Identifícate como artista (Spotify)",
                  style: TextStyle(color: _artistaSpotifySeleccionat != null ? Colors.white : Colors.black45, fontWeight: FontWeight.bold)),
              Icon(Icons.search, color: _artistaSpotifySeleccionat != null ? Colors.white : Colors.black54),
            ],
          ),
        ),
      ),
    );
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
            elevation: 5,
          ),
          onPressed: onPressed,
          child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          radius: 20,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context, _usuariLocal),
          ),
        ),
      ],
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
            style: const TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              filled: true, fillColor: Colors.white,
              suffixIcon: Icon(icon, color: Colors.black54),
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
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white30)
            ),
            child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}