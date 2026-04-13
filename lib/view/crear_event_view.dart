import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flowvenue/view/buscar_artista_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowvenue/model/party_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flowvenue/services/spotifyServices.dart';

class CrearEventView extends StatefulWidget {
  const CrearEventView({super.key});

  @override
  State<CrearEventView>  createState() => _CrearEventViewState();
}

class _CrearEventViewState extends State<CrearEventView> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _localizacionController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _artistasController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();

  // Variable per guardar la imatge seleccionada
  File? _imatgeSeleccionada;

  @override
  void dispose() {
    _nombreController.dispose();
    _fechaController.dispose();
    _localizacionController.dispose();
    _urlController.dispose();
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
      setState(() {
        _imatgeSeleccionada = File(imatge.path);
      });
    }
  }

  // --- FUNCIÓ PER OBRIR EL CALENDARI ---
  Future<void> _seleccionarData() async {
    DateTime? dataEscollida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // No permetre dates passades
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE94E77), // Color de la capçalera
              onPrimary: Colors.white, // Color del text de la capçalera
              onSurface: Colors.black, // Color dels dies
            ),
          ),
          child: child!,
        );
      },
    );

    if (dataEscollida != null) {
      setState(() {
                _fechaController.text = "${dataEscollida.day}/${dataEscollida.month}/${dataEscollida.year}";
      });
    }
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
                              onPressed: () async {
                                // Aquí s'enviarien les dades a Firebase
                                // 1. Validacions
                                if (_nombreController.text.isEmpty ||
                                    _fechaController.text.isEmpty ||
                                    _codigoController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text(
                                        'Por favor, rellena los campos obligatorios'),
                                        backgroundColor: Colors.green),
                                  );
                                  return;
                                }

                                try {

                                  // Mostrar un indicador de càrrega per si la foto triga uns segons a pujar
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFE94E77))),
                                  );

                                  List<String> dateParts = _fechaController.text.split('/');
                                  DateTime fechaFesta = DateTime(
                                      int.parse(dateParts[2]),
                                      int.parse(dateParts[1]),
                                      int.parse(dateParts[0])
                                  );

                                  double preuFesta = double.tryParse(_precioController.text) ?? 0.0;

                                  // --- 2. PUJAR LA IMATGE A FIREBASE STORAGE ---
                                  String imatgeUrl = ''; // Si no n'hi ha, es quedarà buit

                                  if (_imatgeSeleccionada != null) {
                                    String nomArxiu = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
                                    Reference ref = FirebaseStorage.instance.ref().child('festes_images/$nomArxiu');

                                    UploadTask uploadTask = ref.putFile(_imatgeSeleccionada!);
                                    TaskSnapshot snapshot = await uploadTask;
                                    imatgeUrl = await snapshot.ref.getDownloadURL();
                                  }

                                  // 3. Crear objecte Festa sense el ID
                                  Festa novaFesta = Festa(
                                    partyId: '', // ID buit inicialment
                                    serveiId: 1, // ID del Servei creador (agafar de l'usuari actual)
                                    djId: 0,
                                    codiAcces: int.parse(_codigoController.text),
                                    name: _nombreController.text,
                                    fechaEvento: fechaFesta,
                                    actividad: true,
                                    tipoFesta: [_artistasController.text],
                                  );

                                  // CONVERTIM A MAP I AFEGIM EL PREU I LA LOCALITZACIÓ
                                  Map<String, dynamic> festaData = novaFesta.toFirestore();
                                  festaData['precio'] = preuFesta;
                                  festaData['localizacion'] = _localizacionController.text;
                                  festaData['imatge'] = imatgeUrl;

                                  // 4. Pujar a Firebase Firestore i obtenir el ID
                                  DocumentReference docRef = await FirebaseFirestore.instance
                                      .collection('festes')
                                      .add(festaData);

                                  print("Festa creada a Firebase! PartyID: ${docRef.id}");

                                  await FirebaseFirestore.instance.collection('agenda').add({
                                    'partyId': docRef.id,
                                    'userId': 1, // Caldrà posar l'usuari actual més endavant
                                    'name': _nombreController.text,
                                    'fechaEvento': fechaFesta,
                                    'precio': preuFesta,
                                    'localizacion': _localizacionController.text,
                                    'imatge': imatgeUrl,
                                  });

                                  if (mounted) Navigator.pop(context);


                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Evento creado correctamente!'), backgroundColor: Colors.green),
                                  );

                                  Navigator.pop(context);

                                } catch (e) {
                                  if (mounted) Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error al crear evento: $e'), backgroundColor: Colors.red),
                                  );
                                }

                                },

                              child: const Text(
                                "Crear Evento",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
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



  // --- WIDGETS AUXILIARS ---

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
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                image: _imatgeSeleccionada != null
                    ? DecorationImage(image: FileImage(_imatgeSeleccionada!), fit: BoxFit.cover)
                    : null,
              ),
              child: _imatgeSeleccionada == null
                  ? const Icon(Icons.image, size: 60, color: Colors.black)
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: _seleccionarImatge,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1B1CB),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, size: 20, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text("Imagen del Evento", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }


  // Textfield per a Data i Localització (Són ReadOnly i s'activen al fer-hi clic)
  Widget _buildReadOnlyField(String label, TextEditingController controller, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            readOnly: true, // L'usuari no pot escriure lliurement
            onTap: onTap, // Executa la funció (calendari o mapa)
            style: const TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistasField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Artistas Invitados", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 5),
          TextField(
            controller: _artistasController,
            readOnly: true, // Bloquegem el teclat
            onTap: () async {
              // Naveguem i esperem resposta
              final String? nomArtista = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BuscarArtistaView()),
              );

              // Si ha triat un artista, l'afegim al controlador
              if (nomArtista != null) {
                setState(() {
                  if (_artistasController.text.isEmpty) {
                    _artistasController.text = nomArtista;
                  } else {
                    _artistasController.text += ", $nomArtista"; // Afegim amb coma si ja n'hi ha un altre
                  }
                });
              }
            },
            style: const TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold), // Color rosa com demanes
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              hintText: "Toca para buscar artista",
              hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  // Textfield especial pel Codi (5 números)
  Widget _buildCodeField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number, // Obre teclat numèric
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // NOMÉS NÚMEROS
              LengthLimitingTextInputFormatter(5),    // MÀXIM 5 DÍGITS
            ],
            style: const TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold, letterSpacing: 2.0),
            onChanged: (value) {
              // Si d'alguna manera intenten enganxar text invàlid, podem avisar-los
              if (value.contains(RegExp(r'[A-Za-z]'))) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El código solo puede contener números.'), backgroundColor: Colors.red),
                );
              }
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}

