import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flowvenue/view/buscar_artista_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowvenue/model/party_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import 'package:flowvenue/services/spotifyServices.dart';

class CrearEventView extends StatefulWidget {
  const CrearEventView({super.key});

  @override
  State<CrearEventView>  createState() => _CrearEventViewState();
}

class _CrearEventViewState extends State<CrearEventView> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaInicioController = TextEditingController();
  final TextEditingController _horaFinController = TextEditingController();
  final TextEditingController _localizacionController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _estilosController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _artistasController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();

  final List<String> _opcionesEstilos = ["Reggaeton", "Techno", "Trap", "Pop", "Rock", "House", "Indie", "Salsa", "Bachata"];
  List<String> _estilosSeleccionados = [];


  // Variable per guardar la imatge seleccionada
  XFile? _imatgeXFile;
  Uint8List? _imatgeBytes;

  @override
  void dispose() {
    _nombreController.dispose();
    _fechaController.dispose();
    _localizacionController.dispose();
    _urlController.dispose();
    _estilosController.dispose();
    _precioController.dispose();
    _artistasController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  // --- FUNCIÓ PER SELECCIONAR IMATGE ---
  Future<void> _seleccionarImatge() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imatge = await picker.pickImage(source: ImageSource.gallery);

    if (imatge != null) {
      final bytes = await imatge.readAsBytes();
      setState(() {
        _imatgeXFile = imatge;
        _imatgeBytes = bytes;
      });
    }
  }

  // --- FUNCIÓ PER OBRIR EL CALENDARI ---
  Future<void> _seleccionarData() async {
    DateTime? dataEscollida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFE94E77)),
        ),
        child: child!,
      ),
    );
    if (dataEscollida != null) {
      setState(() => _fechaController.text = "${dataEscollida.day}/${dataEscollida.month}/${dataEscollida.year}");
    }
  }

  Future<void> _seleccionarHoraInici() async {
    TimeOfDay? t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) {
      setState(() => _horaInicioController.text = t.format(context));
    }
  }

  // NOU: Selector d'hora final
  Future<void> _seleccionarHoraFi() async {
    TimeOfDay? t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) {
      setState(() => _horaFinController.text = t.format(context));
    }
  }



  void _mostrarSelectorEstilos() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Estilos de Música"),
              content: SingleChildScrollView(
                child: Column(
                  children: _opcionesEstilos.map((estilo) {
                    return CheckboxListTile(
                      activeColor: const Color(0xFFE94E77),
                      title: Text(estilo),
                      value: _estilosSeleccionados.contains(estilo),
                      onChanged: (bool? selected) {
                        setDialogState(() {
                          if (selected == true) {
                            _estilosSeleccionados.add(estilo);
                          } else {
                            _estilosSeleccionados.remove(estilo);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() => _estilosController.text = _estilosSeleccionados.join(", "));
                    Navigator.pop(context);
                  },
                  child: const Text("Confirmar", style: TextStyle(color: Color(0xFFE94E77))),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- FUNCIÓ PER SIMULAR EL MAPA ---
  void _obrirMapaSimulat() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 250,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  color: Colors.grey, // Aquí aniria el Google Maps real
                ),
                child: const Center(
                  child: Icon(Icons.location_on, color: Colors.red, size: 50),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    const Text("Selecciona la ubicación", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE94E77)),
                      onPressed: () {
                        setState(() {
                          _localizacionController.text = "Carrer Major 12, Lleida"; // Ubicació d'exemple
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Confirmar", style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              )
            ],
          ),
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
                        children: [
                        const SizedBox(height: 10),
                    _buildHeader(),
                    const SizedBox(height: 20),

                    // CERCLE DE LA IMATGE
                    _buildImagePicker(),
                    const SizedBox(height: 30),

                    // FORMULARI (Tot seguit, com un carrusel vertical)
                    _buildTextField("Nombre", _nombreController),

                    // Camp de data que obre el calendari
                    _buildReadOnlyField("Fecha", _fechaController, onTap: _seleccionarData),

                    // Camp de localització que obre el mapa
                    _buildReadOnlyField("Localización", _localizacionController, onTap: _obrirMapaSimulat),

                    _buildTextField("URL", _urlController, keyboardType: TextInputType.url),



                    _buildTextField("Precio", _precioController, keyboardType: TextInputType.number),

                          _buildEstilosField(),
                          _buildArtistasField(),

                    // CAMP CODI D'ACCÉS (Màxim 5, només números, avís si hi ha text)
                    _buildCodeField("Código de Acceso (max 5num)", _codigoController),

                    const SizedBox(height: 40),

                          // BOTÓ CREAR EVENTO
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD988B9),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 5,
                              ),
                              onPressed: _crearEventoFirebase,
                              child: const Text("Crear Evento", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text("©2026 FlowVenue by Oriol&Jan", style: TextStyle(color: Colors.white54, fontSize: 10)),
                          const SizedBox(height: 20),
                        ],
                    ),
                ),
            ),
        ),
    );
  }

  // --- LOGICA DE FIREBASE ---

  Future<void> _crearEventoFirebase() async {
    if (_nombreController.text.isEmpty || _fechaController.text.isEmpty || _codigoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rellena los campos obligatorios')));
      return;
    }

    try {
      showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFE94E77))));

      String urlDescarrega = '';
      if (_imatgeBytes != null) {
        String idImatge = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref = FirebaseStorage.instance.ref().child('festes_images/$idImatge.jpg');

        // CORRECCIÓ: putData és compatible amb Web i Mòbil quan fem servir bytes
        await ref.putData(_imatgeBytes!);
        urlDescarrega = await ref.getDownloadURL();
      }

      List<String> dateParts = _fechaController.text.split('/');
      DateTime fechaFesta = DateTime(int.parse(dateParts[2]), int.parse(dateParts[1]), int.parse(dateParts[0]));

      Map<String, dynamic> dadesPerEnviar = {
        'nom': _nombreController.text,
        'name': _nombreController.text,
        'fecha_evento': fechaFesta,
        'localizacion': _localizacionController.text,
        'precio': double.tryParse(_precioController.text) ?? 0.0,
        'imatge': urlDescarrega,
        'codiAcces': int.parse(_codigoController.text),
        'artista': _artistasController.text,
        'tipoFesta': _estilosSeleccionados, // Guardat com a Array
        'actividad': true,
      };

      await FirebaseFirestore.instance.collection('festes').add(dadesPerEnviar);

      if (mounted) Navigator.pop(context); // Tanca loding
      Navigator.pop(context); // Torna enrere
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Evento creado!'), backgroundColor: Colors.green));

    } catch (e) {
      if (mounted) Navigator.pop(context);
      print("Error: $e");
    }
  }

  // --- WIDGETS AUXILIARS ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        Image.asset('assets/Logo_FlowVenue.png', height: 40),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _seleccionarImatge,
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.white,
        backgroundImage: _imatgeBytes != null ? MemoryImage(_imatgeBytes!) : null,
        child: _imatgeBytes == null ? const Icon(Icons.camera_alt, size: 40, color: Colors.black) : null,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return _baseField(label, TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold),
      decoration: _inputDeco(),
    ));
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller, {required VoidCallback onTap}) {
    return _baseField(label, TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: const TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold),
      decoration: _inputDeco(),
    ));
  }

  Widget _buildEstilosField() {
    return _buildReadOnlyField("Estilos de Música", _estilosController, onTap: _mostrarSelectorEstilos);
  }

  Widget _buildArtistasField() {
    return _buildReadOnlyField("Artistas Invitados", _artistasController, onTap: () async {
      final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const BuscarArtistaView()));
      if (result != null) setState(() => _artistasController.text.isEmpty ? _artistasController.text = result : _artistasController.text += ", $result");
    });
  }

  Widget _buildCodeField(String label, TextEditingController controller) {
    return _baseField(label, TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
      style: const TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold),
      decoration: _inputDeco(),
    ));
  }

  // Helpers de disseny
  Widget _baseField(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 5),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDeco() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    );
  }
}
