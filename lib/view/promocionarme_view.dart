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
  final Map<DateTime, List<Map<String, String>>> _eventsPerDia = {};
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nomArtistaSpotify ?? "");
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcioController.dispose();
    super.dispose();
  }

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  // --- FUNCIÓ PER GUARDAR A FIREBASE ---
  Future<void> _guardarPromocio() async {
    if (_nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, indica tu nombre artístico')),
      );
      return;
    }

    try {
      // Preparem l'agenda per guardar-la (keys com a ISO Strings)
      Map<String, dynamic> agendaFirestore = {};
      _eventsPerDia.forEach((key, value) {
        agendaFirestore[key.toIso8601String()] = value;
      });

      await FirebaseFirestore.instance.collection('festes').add({
        'nom': _nombreController.text,
        'artista': _nombreController.text,
        'descripcio': _descripcioController.text,
        'tipus': 'artista', // DIFERENCIADOR CLAU
        'fecha_evento': Timestamp.now(), // Data de promoció (per defecte avui)
        'localizacion': 'Disponible para eventos',
        'precio': 0.0,
        'agenda': agendaFirestore,
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Promoción activada! Ahora eres visible en el buscador.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al promocionar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _mostrarPopUpEventos(DateTime diaSeleccionat) {
    DateTime normalizedDay = _normalizeDate(diaSeleccionat);
    TextEditingController _nuevoEventoController = TextEditingController();
    bool isAdding = false;
    TimeOfDay? _selectedTime;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            List<Map<String, String>> eventosDelDia = _eventsPerDia[normalizedDay] ?? [];

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                "Agenda - ${diaSeleccionat.day}/${diaSeleccionat.month}",
                style: const TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (eventosDelDia.isEmpty && !isAdding)
                      const Text("Día libre de eventos.", style: TextStyle(color: Colors.grey)),
                    if (eventosDelDia.isNotEmpty)
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: eventosDelDia.length,
                          itemBuilder: (context, index) {
                            final evento = eventosDelDia[index];
                            return Card(
                              color: const Color(0xFFF1B1CB),
                              child: ListTile(
                                title: Text(evento['nombre']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                subtitle: Text(evento['hora']!, style: const TextStyle(color: Colors.white70)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.white),
                                  onPressed: () {
                                    setStateDialog(() {
                                      _eventsPerDia[normalizedDay]!.removeAt(index);
                                      if (_eventsPerDia[normalizedDay]!.isEmpty) _eventsPerDia.remove(normalizedDay);
                                    });
                                    setState(() {});
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (isAdding)
                      Column(
                        children: [
                          TextField(
                            controller: _nuevoEventoController,
                            decoration: const InputDecoration(hintText: "Nombre del evento..."),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                              if (picked != null) setStateDialog(() => _selectedTime = picked);
                            },
                            icon: const Icon(Icons.access_time),
                            label: Text(_selectedTime?.format(context) ?? "Elegir hora"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_nuevoEventoController.text.isNotEmpty && _selectedTime != null) {
                                setStateDialog(() {
                                  _eventsPerDia.putIfAbsent(normalizedDay, () => []).add({
                                    'nombre': _nuevoEventoController.text,
                                    'hora': _selectedTime!.format(context),
                                  });
                                  isAdding = false;
                                });
                                setState(() {});
                              }
                            },
                            child: const Text("Añadir"),
                          )
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                if (!isAdding)
                  TextButton(onPressed: () => setStateDialog(() => isAdding = true), child: const Text("+ Nuevo")),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/Background_App.png'), fit: BoxFit.cover)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                const Center(child: Text("Perfil de Artista", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
                const SizedBox(height: 30),
                _buildTextField("Nombre del Artista", _nombreController),
                const SizedBox(height: 15),
                _buildTextField("Descripción / Estilos", _descripcioController, maxLines: 3),
                const SizedBox(height: 30),
                const Text("Agenda de Disponibilidad", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildCalendari(),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD988B9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    onPressed: _guardarPromocio,
                    child: const Text("Guardar y Promocionarme", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context))),
      Image.asset('assets/Logo_FlowVenue.png', height: 50),
      const SizedBox(width: 40),
    ],
  );

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(height: 5),
      TextField(
        controller: controller, maxLines: maxLines,
        style: const TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold),
        decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)),
      ),
    ],
  );

  Widget _buildCalendari() => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    padding: const EdgeInsets.all(10),
    child: TableCalendar(
      firstDay: DateTime.now(), lastDay: DateTime.now().add(const Duration(days: 365)), focusedDay: _focusedDay,
      selectedDayPredicate: (day) => _eventsPerDia.containsKey(_normalizeDate(day)),
      onDaySelected: (selectedDay, focusedDay) { setState(() => _focusedDay = focusedDay); _mostrarPopUpEventos(selectedDay); },
      headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
    ),
  );
}