import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import '/model/users_model.dart';

class AgendaView extends StatefulWidget {
  final Usuari usuariActual;
  const AgendaView({super.key, required this.usuariActual});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Set<String> _diesAmbEsdeveniments = {};

  @override
  void initState() {
    super.initState();
    _escudarEsdeveniments();
  }

  DateTime? _normalitzarData(dynamic dataFirestore) {
    if (dataFirestore == null) return null;
    if (dataFirestore is Timestamp) return dataFirestore.toDate();
    if (dataFirestore is String) return DateTime.tryParse(dataFirestore);
    return null;
  }

  void _escudarEsdeveniments() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.usuariActual.userId)
        .collection('agenda')
        .snapshots()
        .listen((snapshot) {
      final tempDies = <String>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        DateTime? dt = _normalitzarData(data['data']);
        if (dt != null) {
          tempDies.add("${dt.year}-${dt.month}-${dt.day}");
        }
      }
      setState(() {
        _diesAmbEsdeveniments = tempDies;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/Background_App.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const Text("Agenda de Eventos",
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),

              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: SingleChildScrollView( // Embolcallem NOMÉS el contingut intern per evitar l'overflow
                    child: TableCalendar(
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2101),
                      focusedDay: _focusedDay,
                      locale: 'es_ES',
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        _mostrarEtiquetesDelDia(selectedDay);
                      },
                      // AIXÒ ÉS EL QUE PINTA ELS CERCLES ROSES
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          String key = "${date.year}-${date.month}-${date.day}";
                          if (_diesAmbEsdeveniments.contains(key)) {
                            return Positioned(
                              bottom: 1,
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFE94E77),
                                ),
                                width: 7,
                                height: 7,
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      calendarStyle: CalendarStyle(
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFFE94E77),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: const Color(0xFFE94E77).withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _buildAddButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- RESTA DE MÈTODES (Header, AddButton, Dialogs) ES MANTENEN IGUAL ---
  Widget _buildHeader() => Padding(padding: const EdgeInsets.all(20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))), Image.asset('assets/Logo_FlowVenue.png', height: 40), const SizedBox(width: 40)]));

  Widget _buildAddButton() => ElevatedButton.icon(onPressed: () => _showAddLabelDialog(), icon: const Icon(Icons.add_circle_outline, color: Colors.white), label: const Text("Añadir Etiqueta", style: TextStyle(color: Colors.white, fontSize: 18)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD988B9), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))));

  void _mostrarEtiquetesDelDia(DateTime date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Día ${date.day}/${date.month}"),
        content: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(widget.usuariActual.userId).collection('agenda').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              var docs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                DateTime? dt = _normalitzarData(data['data']);
                return dt != null && dt.year == date.year && dt.month == date.month && dt.day == date.day;
              }).toList();
              if (docs.isEmpty) return const Text("No hay eventos.");
              return SizedBox(width: double.maxFinite, child: ListView.builder(shrinkWrap: true, itemCount: docs.length, itemBuilder: (context, index) {
                var data = docs[index].data() as Map<String, dynamic>;
                return Card(color: const Color(0xFFE94E77).withOpacity(0.1), child: ListTile(title: Text(data['titol'] ?? "Evento"), subtitle: Text("${data['tipus'] ?? 'Gral'} • ${data['hora'] ?? ''}")));
              }));
            }
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar"))],
      ),
    );
  }

  void _showAddLabelDialog() {
    final TextEditingController ctrl = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(title: const Text("Nueva Etiqueta"), content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: "Nombre del evento")), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")), ElevatedButton(onPressed: () async { if (ctrl.text.isNotEmpty) { await FirebaseFirestore.instance.collection('users').doc(widget.usuariActual.userId).collection('agenda').add({'titol': ctrl.text, 'data': Timestamp.fromDate(_selectedDay), 'tipus': "Manual", 'hora': "Todo el día"}); Navigator.pop(context); } }, child: const Text("Guardar"))]));
  }
}