import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class PromocionarmeView extends StatefulWidget {
  final String? nomArtistaSpotify;
  const PromocionarmeView({super.key, this.nomArtistaSpotify});

  @override
  State<PromocionarmeView> createState() => _PromocionarmeViewState();
}

class _PromocionarmeViewState extends State<PromocionarmeView> {
  late TextEditingController _nombreController;
  final TextEditingController _descripcioController = TextEditingController();
  Map<DateTime, List<Map<String, String>>> _eventsPerDia = {};
  DateTime _focusedDay = DateTime.now();
  String? _documentIdExistent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nomArtistaSpotify ?? "");
    _comprovarPromocioExistent();
  }

  Future<void> _comprovarPromocioExistent() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('festes')
          .where('tipus', isEqualTo: 'artista')
          .where('artista', isEqualTo: widget.nomArtistaSpotify)
          .limit(1).get();

      if (query.docs.isNotEmpty) {
        var doc = query.docs.first;
        _documentIdExistent = doc.id;
        _descripcioController.text = doc['descripcio'] ?? "";
        if (doc['agenda'] != null) {
          Map<String, dynamic> dataAgenda = Map<String, dynamic>.from(doc['agenda']);
          dataAgenda.forEach((key, value) {
            DateTime dt = DateTime.parse(key);
            _eventsPerDia[DateTime(dt.year, dt.month, dt.day)] = List<Map<String, String>>.from((value as List).map((e) => Map<String, String>.from(e)));
          });
        }
      }
    } catch (e) { print("Error en cerca: $e"); }
    setState(() => _isLoading = false);
  }

  Future<void> _guardarPromocio() async {
    if (_nombreController.text.isEmpty) return;

    Map<String, dynamic> agendaMap = {};
    _eventsPerDia.forEach((key, value) => agendaMap[key.toIso8601String()] = value);

    Map<String, dynamic> dades = {
      'nom': _nombreController.text,
      'artista': _nombreController.text,
      'descripcio': _descripcioController.text,
      'tipus': 'artista',
      'agenda': agendaMap,
      'updated_at': FieldValue.serverTimestamp(),
    };

    try {
      // 1. Guardem a la col·lecció general de 'festes' (públic)
      if (_documentIdExistent != null) {
        await FirebaseFirestore.instance.collection('festes').doc(_documentIdExistent).update(dades);
      } else {
        dades['created_at'] = FieldValue.serverTimestamp();
        dades['fecha_evento'] = Timestamp.now();
        dades['localizacion'] = 'Disponible';
        dades['precio'] = 0.0;
        await FirebaseFirestore.instance.collection('festes').add(dades);
      }

      // 2. IMPLEMENTACIÓ A L'AGENDA PERSONAL (El que m'has demanat)
      // Recorrem tots els dies que l'artista ha marcat a la seva agenda
      for (var entry in _eventsPerDia.entries) {
        DateTime dia = entry.key;
        List eventsDelDia = entry.value;

        for (var ev in eventsDelDia) {
          // Creem un ID únic per a cada esdeveniment per evitar duplicats si tornen a desar
          String eventId = "PROMO_${dia.millisecondsSinceEpoch}_${ev['nombre']}";

          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.nomArtistaSpotify) // Aquí usem el nom de l'artista com a ID de l'usuari
              .collection('agenda')
              .doc(eventId)
              .set({
            'titol': "Promoción: ${ev['nombre']}",
            'data': Timestamp.fromDate(dia),
            'tipus': "Promoción Artista",
            'hora': ev['hora'] ?? "22:00",
          });
        }
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Perfil y Agenda actualizados!")),
      );

    } catch (e) {
      print("Error al guardar: $e");
    }
  }

  void _mostrarPopUpAgenda(DateTime dia) {
    DateTime norm = DateTime(dia.year, dia.month, dia.day);
    TextEditingController _evCont = TextEditingController();
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setD) {
      List events = _eventsPerDia[norm] ?? [];
      return AlertDialog(
        title: Text("Agenda ${norm.day}/${norm.month}"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          ...events.map((e) => ListTile(title: Text(e['nombre']!), subtitle: Text(e['hora']!), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setD(() => setState(() { _eventsPerDia[norm]!.remove(e); if(_eventsPerDia[norm]!.isEmpty) _eventsPerDia.remove(norm); }))))),
          TextField(controller: _evCont, decoration: const InputDecoration(hintText: "Nombre del evento")),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cerrar")),
          ElevatedButton(onPressed: () { if(_evCont.text.isNotEmpty) setState(() { _eventsPerDia.putIfAbsent(norm, () => []).add({'nombre': _evCont.text, 'hora': '22:00'}); }); Navigator.pop(ctx); }, child: const Text("Añadir"))
        ],
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Container( // El Container amb la imatge va PRIMER
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/Background_App.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Fem el Scaffold transparent per veure el fons
        body: SafeArea(
          child: Column( // Utilitzem Column + Expanded per assegurar que el contingut ocupi l'espai
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        _documentIdExistent != null ? "Editar Perfil" : "Promocionarme",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildTextField("Nombre Artístico", _nombreController),
                      const SizedBox(height: 15),
                      _buildTextField("Descripción", _descripcioController, maxLines: 3),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TableCalendar(
                          firstDay: DateTime.now(),
                          lastDay: DateTime.now().add(const Duration(days: 365)),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) =>
                              _eventsPerDia.containsKey(DateTime(day.year, day.month, day.day)),
                          onDaySelected: (sel, foc) {
                            setState(() => _focusedDay = foc);
                            _mostrarPopUpAgenda(sel);
                          },
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD988B9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _guardarPromocio,
                          child: Text(
                            _documentIdExistent != null
                                ? "Actualizar Promoción"
                                : "Activar Promoción",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30), // Espai final per al scroll
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))), Image.asset('assets/Logo_FlowVenue.png', height: 50), const SizedBox(width: 40)]);
  Widget _buildTextField(String l, TextEditingController c, {int maxLines = 1}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(height: 5), TextField(controller: c, maxLines: maxLines, decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)))]);
}