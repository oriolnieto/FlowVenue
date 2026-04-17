import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flowvenue/view/buscar_artista_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class CrearEventView extends StatefulWidget {
  const CrearEventView({super.key});

  @override
  State<CrearEventView> createState() => _CrearEventViewState();
}

class _CrearEventViewState extends State<CrearEventView> {
  // --- CONTROLADORS ---
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
  Uint8List? _imatgeBytes;

  @override
  void dispose() {
    _nombreController.dispose();
    _fechaController.dispose();
    _horaInicioController.dispose();
    _horaFinController.dispose();
    _localizacionController.dispose();
    _urlController.dispose();
    _estilosController.dispose();
    _precioController.dispose();
    _artistasController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  // --- SELECCIÓ D'IMATGE ---
  Future<void> _seleccionarImatge() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imatge = await picker.pickImage(source: ImageSource.gallery);

    if (imatge != null) {
      final bytes = await imatge.readAsBytes();
      setState(() => _imatgeBytes = bytes);
    }
  }

  // --- SELECTORS DE DATA I HORA ---
  Future<void> _seleccionarData() async {
    DateTime? data = await showDatePicker(
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
    if (data != null) {
      setState(() => _fechaController.text = "${data.day}/${data.month}/${data.year}");
    }
  }

  Future<void> _seleccionarHoraInici() async {
    TimeOfDay? t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 23, minute: 0));
    if (t != null) setState(() => _horaInicioController.text = t.format(context));
  }

  Future<void> _seleccionarHoraFi() async {
    TimeOfDay? t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 6, minute: 0));
    if (t != null) setState(() => _horaFinController.text = t.format(context));
  }

  // --- LÒGICA DE FIREBASE (Anti-bloqueig) ---
  Future<void> _crearEventoFirebase() async {
    if (_nombreController.text.isEmpty || _fechaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, rellena nombre y fecha')));
      return;
    }

    // Obrim el diàleg de càrrega
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFE94E77))),
    );

    try {
      String urlDescarrega = '';

      // 1. Intentar pujar imatge (si n'hi ha)
      if (_imatgeBytes != null) {
        try {
          String idImatge = DateTime.now().millisecondsSinceEpoch.toString();
          Reference ref = FirebaseStorage.instance.ref().child('festes_images/$idImatge.jpg');
          await ref.putData(_imatgeBytes!);
          urlDescarrega = await ref.getDownloadURL();
        } catch (e) {
          print("Error en Storage: $e");
          // Si falla la imatge, no tallem l'execució, simplement l'event es crea sense foto
        }
      }

      // 2. Format de la data segur
      List<String> dateParts = _fechaController.text.split('/');
      DateTime fechaFesta = DateTime.now();
      if (dateParts.length == 3) {
        fechaFesta = DateTime(int.parse(dateParts[2]), int.parse(dateParts[1]), int.parse(dateParts[0]));
      }

      // 3. Enviament a Firestore
      Map<String, dynamic> dades = {
        'nom': _nombreController.text,
        'name': _nombreController.text,
        'fecha_evento': fechaFesta,
        'hora_inicio': _horaInicioController.text,
        'hora_fin': _horaFinController.text,
        'localizacion': _localizacionController.text,
        'precio': double.tryParse(_precioController.text) ?? 0.0,
        'imatge': urlDescarrega,
        'codi_acces': int.tryParse(_codigoController.text) ?? 0,
        'codiAcces': int.tryParse(_codigoController.text) ?? 0,
        'artista': _artistasController.text,
        'tipoFesta': _estilosSeleccionados,
        'actividad': true,
        'dj_id': 0,
        'servei_id': 1,
      };

      await FirebaseFirestore.instance.collection('festes').add(dades);

      // Si tot va bé, tanquem loading i tornem enrere
      if (mounted) {
        Navigator.pop(context); // Tanca loading
        Navigator.pop(context); // Torna a la llista
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Evento creado con éxito!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      // Si hi ha un error crític, tanquem el loading i avisem
      if (mounted) Navigator.pop(context);
      print("ERROR CRÍTIC: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear evento: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // --- UI COMPONENTS ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/Background_App.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildHeader(),
                const SizedBox(height: 20),
                _buildImagePicker(),
                const SizedBox(height: 30),

                _buildTextField("Nombre del Evento", _nombreController),
                _buildReadOnlyField("Fecha", _fechaController, onTap: _seleccionarData),

                Row(
                  children: [
                    Expanded(child: _buildReadOnlyField("Hora Inicio", _horaInicioController, onTap: _seleccionarHoraInici)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildReadOnlyField("Hora Fin", _horaFinController, onTap: _seleccionarHoraFi)),
                  ],
                ),

                _buildReadOnlyField("Localización", _localizacionController, onTap: () => setState(() => _localizacionController.text = "Lleida, Carrer Major 12")),
                _buildTextField("Precio (€)", _precioController, keyboardType: TextInputType.number),
                _buildReadOnlyField("Estilos de Música", _estilosController, onTap: _mostrarSelectorEstilos),

                _buildReadOnlyField("Artistas Invitados", _artistasController, onTap: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const BuscarArtistaView()));
                  if (result != null) setState(() => _artistasController.text = result);
                }),

                _buildCodeField("Código de Acceso", _codigoController),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity, height: 55,
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

  // --- HELPERS ---
  Widget _buildHeader() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)), Image.asset('assets/Logo_FlowVenue.png', height: 40), const SizedBox(width: 40)]);

  Widget _buildImagePicker() => GestureDetector(onTap: _seleccionarImatge, child: CircleAvatar(radius: 60, backgroundColor: Colors.white, backgroundImage: _imatgeBytes != null ? MemoryImage(_imatgeBytes!) : null, child: _imatgeBytes == null ? const Icon(Icons.camera_alt, size: 40, color: Colors.black) : null));

  Widget _buildTextField(String label, TextEditingController ctrl, {TextInputType keyboardType = TextInputType.text}) => _baseField(label, TextField(controller: ctrl, keyboardType: keyboardType, style: const TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold), decoration: _inputDeco()));

  Widget _buildReadOnlyField(String label, TextEditingController ctrl, {required VoidCallback onTap}) => _baseField(label, TextField(controller: ctrl, readOnly: true, onTap: onTap, style: const TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold), decoration: _inputDeco()));

  Widget _buildCodeField(String label, TextEditingController ctrl) => _baseField(label, TextField(controller: ctrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)], style: const TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold), decoration: _inputDeco()));

  Widget _baseField(String label, Widget child) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(height: 5), child]));

  InputDecoration _inputDeco() => InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15));

  void _mostrarSelectorEstilos() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Selecciona Estilos"),
          content: SingleChildScrollView(
            child: Column(
              children: _opcionesEstilos.map((e) => CheckboxListTile(
                activeColor: const Color(0xFFE94E77),
                title: Text(e),
                value: _estilosSeleccionados.contains(e),
                onChanged: (val) => setDialogState(() => val! ? _estilosSeleccionados.add(e) : _estilosSeleccionados.remove(e)),
              )).toList(),
            ),
          ),
          actions: [TextButton(onPressed: () {
            setState(() => _estilosController.text = _estilosSeleccionados.join(", "));
            Navigator.pop(context);
          }, child: const Text("Confirmar", style: TextStyle(color: Color(0xFFE94E77))))],
        ),
      ),
    );
  }
}