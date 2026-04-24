import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart'; // Utilitzem TableCalendar per la flexibilitat
import '/services/db_services.dart';
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

  // Guardarem els dies que tenen esdeveniments per pintar-los
  Set<String> _diesAmbEsdeveniments = {};

  @override
  void initState() {
    super.initState();
    _escudarEsdeveniments();
  }

  // Escolta en temps real tots els esdeveniments de l'usuari per marcar el calendari
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
        if (data['data'] != null) {
          DateTime dt = (data['data'] as Timestamp).toDate();
          // Guardem la data en format YYYY-MM-DD per comparar fàcilment
          tempDies.add("${dt.year}-${dt.month}-${dt.day}");
        }
      }
      setState(() {
        _diesAmbEsdeveniments = tempDies;
      });
    });
  }

  void _mostrarEtiquetesDelDia(DateTime date) {
    DateTime iniciDia = DateTime(date.year, date.month, date.day);
    DateTime finalDia = iniciDia.add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Día ${date.day}/${date.month}"),
          content: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.usuariActual.userId)
                .collection('agenda')
                .where('data', isGreaterThanOrEqualTo: iniciDia)
                .where('data', isLessThan: finalDia)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              var docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Text("No hay eventos.");

              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    return Card(
                      color: const Color(0xFFE94E77).withOpacity(0.1),
                      child: ListTile(
                        title: Text(data['titol'] ?? "Evento"),
                        subtitle: Text(data['tipus'] ?? "General"),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar"))],
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
          image: DecorationImage(image: AssetImage('assets/Background_App.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const Text("Agenda de Eventos", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),

              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime(2000),
                    lastDay: DateTime(2101),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _mostrarEtiquetesDelDia(selectedDay);
                    },
                    // LÒGICA PER PINTAR EL DIA DE ROSA SI HI HA EVENT
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        String key = "${day.year}-${day.month}-${day.day}";
                        if (_diesAmbEsdeveniments.contains(key)) {
                          return Container(
                            margin: const EdgeInsets.all(4),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1B1CB), // Rosa suau per a dies amb event
                              shape: BoxShape.circle,
                            ),
                            child: Text("${day.day}"),
                          );
                        }
                        return null;
                      },
                    ),
                    headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                      selectedDecoration: BoxDecoration(color: Color(0xFFE94E77), shape: BoxShape.circle),
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

  Widget _buildAddButton() {
    return ElevatedButton.icon(
      onPressed: () => _showAddLabelDialog(),
      icon: const Icon(Icons.add_circle_outline, color: Colors.white),
      label: const Text("Añadir Etiqueta", style: TextStyle(color: Colors.white, fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD988B9),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))),
          Image.asset('assets/Logo_FlowVenue.png', height: 50),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  void _showAddLabelDialog() {
    final TextEditingController _titolController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nueva Etiqueta"),
        content: TextField(controller: _titolController, decoration: const InputDecoration(hintText: "Nombre del evento")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (_titolController.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.usuariActual.userId)
                    .collection('agenda')
                    .add({
                  'titol': _titolController.text,
                  'data': Timestamp.fromDate(_selectedDay),
                  'tipus': "Manual",
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Guardar"),
          )
        ],
      ),
    );
  }
}