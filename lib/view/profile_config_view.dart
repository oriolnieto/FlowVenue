import 'package:flutter/material.dart';

import 'agenda_view.dart';

class PerfilConfigView extends StatefulWidget {
  final String rol; // "Usuario", "Artista" o "Servicio"

  const PerfilConfigView({super.key, required this.rol});

  @override
  State<PerfilConfigView> createState() => _PerfilConfigViewState();
}

class _PerfilConfigViewState extends State<PerfilConfigView> {
  final TextEditingController _nameController = TextEditingController(text: "Jeffrey Epstein");
  final TextEditingController _dniController = TextEditingController(text: "49421432F");
  final TextEditingController _phoneController = TextEditingController(text: "+34 697 564 849");

  String _selectedLanguage = 'Español';
  final List<String> _languages = ['Español', 'Català', 'English'];

  @override
  Widget build(BuildContext context) {
    // Verificació de permisos segons el rol
    bool potCrearEvent = widget.rol == "Servicio";

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
                    // Camps del formulari
                    _buildTextField("Usuario", _nameController, Icons.edit),
                    _buildLanguageDropdown(),
                    _buildTextField("DNI", _dniController, Icons.edit),
                    _buildTextField("Num.Telefono", _phoneController, Icons.edit),
                    _buildReadOnlyField("Rol", widget.rol),

                    const SizedBox(height: 15),

                    // Botó per sol·licitar canvi de rol
                    TextButton(
                      onPressed: () => print("Accediendo a solicitud de rol"),
                      child: const Text("Solicitar cambio de rol",
                          style: TextStyle(color: Colors.white, decoration: TextDecoration.underline, fontSize: 12)),
                    ),

                    const SizedBox(height: 20),

                    // Botó condicional segons el Rol
                    if (potCrearEvent)
                SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD988B9),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),

                    ),
                  onPressed: () => print(""),
                  child: const Text("+ Crear Evento",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
            ),const SizedBox(height: 40),
                          const Text("©2026 FlowVenue by Oriol&Jan",
                              style: TextStyle(color: Colors.white54, fontSize: 10)),
                        ],
                    ),
                ),
            ),
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
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Image.asset('assets/Logo_FlowVenue.png', height: 50),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildProfileImage() {
    return SizedBox(
      width: 250, // Una mica més ample per evitar que se solapin
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cercle principal de la foto de perfil (Centre)
          const CircleAvatar(
            radius: 60,
            backgroundColor: Color(0xFFF1B1CB),
            child: Icon(Icons.person, size: 70, color: Colors.black),
          ),

          // ICONA DE L'AGENDA (Esquerra inferior)
          Positioned(
            left: 10, // A l'esquerra
            bottom: 10,
            child: _buildFloatingButton(Icons.calendar_month, () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AgendaView()),
              );
            }),
          ),

          // ICONA D'EDITAR (Dreta inferior)
          Positioned(
            right: 10, // CANVIAT A RIGHT per veure les dues icones
            bottom: 10,
            child: _buildFloatingButton(Icons.edit_note, () {
              print("Editant perfil...");
            }),
          ),
        ],
      ),
    );
  }

// Funció auxiliar (es manté igual, està perfecta)
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

  Widget _buildLanguageDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Idioma", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLanguage,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                items: _languages.map((String lang) {
                  return DropdownMenuItem(value: lang, child: Text(lang, style: const TextStyle(color: Color(0xFFE94E77))));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = newValue!;
                    // Aquí cridaries a la funció per canviar el Locale de l'App
                  });
                },
              ),
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