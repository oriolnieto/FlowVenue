import 'package:flutter/material.dart';
import 'package:flowvenue/model/users_model.dart';
import 'package:flowvenue/view/profile_config_view.dart';

class solicitud_rol_view extends StatefulWidget {
  final Usuari usuariActual;

  const solicitud_rol_view
      ({super.key, required this.usuariActual});

  @override
  State<solicitud_rol_view> createState() => _solicitud_rol_viewState();
}

class _solicitud_rol_viewState extends State<solicitud_rol_view> {
  final TextEditingController _raoController = TextEditingController();
  String? _rolDesitjat;

  late List<String> _rolsDisponibles;

  @override
  void initState() {
    super.initState();
    List<String> totsElsRols = ['Usuario', 'Artista', 'Servicio'];

    String rolActualNormalitzat = widget.usuariActual.role.toLowerCase();

    _rolsDisponibles = totsElsRols.where((rol) {
      return rol.toLowerCase() != rolActualNormalitzat;
    }).toList();
    if (_rolsDisponibles.isNotEmpty) {
      _rolDesitjat = _rolsDisponibles.first;
    }
  }

  @override
  void dispose() {
    _raoController.dispose();
    super.dispose();
  }

  void _mostrarPopUpConfirmacio() {
    if (_raoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, indica una razón para el cambio de rol.')),
      );
      return;
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              title: const Text('Confirmar Solicitud',
                  style: TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold)),
              content: Text(
                '¿Estás seguro de que quieres solicitar el cambio a $_rolDesitjat?'
                    ' Recibirás un correo electrónico en los próximos días con toda la información '
                    'y la resolución de tu solicitud en base a la razón que nos has proporcionado.',
                style: const TextStyle(color: Colors.black87),
              ),

              actions: [
              TextButton(
              onPressed: () => Navigator.of(context).pop(), // Tanca el pop-up (NO)
              child: const Text('No', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),

          ElevatedButton(
          style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD988B9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),

          onPressed: () {
          print("Sol·licitud enviada per a ser $_rolDesitjat. Raó: ${_raoController.text}");

          Navigator.of(context).pop(); // Tanca el pop-up
          Navigator.of(context).pop(); // Torna a la pantalla de Perfil

          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud enviada correctamente.'), backgroundColor: Colors.green),
          );

          },
            child: const Text('Sí, enviar', style: TextStyle(color: Colors.white)),
          ),
              ],
          );
        },
    );
  }

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
            child: SafeArea(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        const SizedBox(height: 10),
                    _buildHeader(),
                    const SizedBox(height: 40),

                    // Títol de la pantalla
                    const Center(
                      child: Text(
                        "Solicitud de cambio de rol",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Camp de text gran per a la raó
                    const Text(
                      "Porque deseas cambiar de rol?",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _raoController,
                      maxLines: 5, // Fa que la caixa sigui gran com a la imatge
                      style: const TextStyle(color: Color(0xFFE94E77)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none
                        ),
                        contentPadding: const EdgeInsets.all(15),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Desplegable de rols
                    const Text(
                      "Rol deseado",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),

                    const SizedBox(height: 10),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25)
                        ),

                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _rolDesitjat,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 30),
                          items: _rolsDisponibles.map((String rol) {
                            return DropdownMenuItem(
                                value: rol,
                                child: Text(rol, style: const TextStyle(color: Color(0xFFE94E77)))
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _rolDesitjat = newValue;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Botó Aceptar Cambio de Rol
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD988B9), // Color rosa del botó
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)
                            ),
                            elevation: 5, // Ombra com a la imatge
                          ),
                          onPressed: _mostrarPopUpConfirmacio,
                          child: const Text(
                            "Aceptar Cambio de Rol",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ),
                    ),

                          const SizedBox(height: 40),
                          const Center(
                            child: Text("©2026 FlowVenue by Oriol&Jan",
                                style: TextStyle(color: Colors.white54, fontSize: 10)),
                          ),
                        ],
                    ),
                ),
            ),
        ),
    );
  }


// Header exactament igual que a la pantalla de Perfil
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          radius: 20,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Image.asset('assets/Logo_FlowVenue.png', height: 50),
        const SizedBox(width: 40), // Per centrar el logo
      ],
    );
  }
}