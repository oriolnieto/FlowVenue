import 'package:flutter/material.dart';

class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Funció per mostrar el Pop-up de selecció de dia i hora
  Future<void> _showAddLabelDialog() async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Afegir Etiqueta',
                  style: TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: ListBody(
                    children: <Widget>[
                const Text('Selecciona el moment per a la teva etiqueta:'),
                const SizedBox(height: 20),
                // Botó Seleccionar Dia
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text("Seleccionar Dia"),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF1B1CB)),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                ),

                      // Botó Seleccionar Hora
                      ElevatedButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: const Text("Seleccionar Hora"),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF1B1CB)),
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (picked != null) setState(() => _selectedTime = picked);
                        },
                      ),
                    ],
                ),
              ),

            actions: <Widget>[
              TextButton(
                child: const Text('Cancel·lar', style: TextStyle(color: Colors.grey)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Guardar', style: TextStyle(color: Color(0xFFE94E77))),
                onPressed: () {
                  // Aquí guardaries l'etiqueta
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Etiqueta afegida correctament'))
                  );
                },
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
              child: Column(
                  children: [
                  _buildHeader(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Agenda de Eventos",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // CALENDARI INTERACTIU
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: CalendarDatePicker(
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    onDateChanged: (date) {
                      setState(() => _selectedDate = date);
                    },
                  ),
                ),
              ),

                    // BOTÓ AFEGIR ETIQUETA
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ElevatedButton.icon(
                        onPressed: _showAddLabelDialog,
                        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                        label: const Text("Añadir Etiqueta",
                            style: TextStyle(color: Colors.white, fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD988B9),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),

                    const Text(
                      "©2026 FlowVenue by Oriol&Jan",
                      style: TextStyle(color: Colors.white54, fontSize: 10),
                    ),
                    const SizedBox(height: 10),
                  ],
              ),
            ),
        ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
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
      ),
    );
  }
}