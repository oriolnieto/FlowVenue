import 'package:flutter/material.dart';


class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Simulació de dades: Map on la clau és el dia (YYYY-MM-DD) i el valor una llista d'etiquetes
  final Map<String, List<String>> _etiquetesPerDia = {
    "2026-03-12": ["Mandanga Meme Party - 23:00", "Recollir entrades"],
    "2026-03-15": ["Sopar FlowVenue", "Aniversari Jan"],
    "2026-03-20": ["Concert Alvama Ice"],
  };

  // 1. POP-UP PER VEURE ETIQUETES EXISTENTS
  void _mostrarEtiquetesDelDia(DateTime date) {
    String dateKey = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    List<String> etiquetes = _etiquetesPerDia[dateKey] ?? [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.event_note, color: Color(0xFFE94E77)),
              const SizedBox(width: 10),
              Text("Día ${date.day}/${date.month}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: etiquetes.isEmpty
                ? const Text("No hay etiquetas para este día.",
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))
                : ListView.builder(
              shrinkWrap: true,
              itemCount: etiquetes.length,
              itemBuilder: (context, index) {
                return Card(
                  color: const Color(0xFFF1B1CB).withOpacity(0.3),
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: const Icon(Icons.label, color: Color(0xFFE94E77), size: 20),
                    title: Text(etiquetes[index], style: const TextStyle(fontSize: 14)),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar", style: TextStyle(color: Color(0xFFE94E77))),
            ),
          ],
        );
      },
    );
  }

  // 2. POP-UP PER AFEGIR UNA NOVA ETIQUETA
  Future<void> _showAddLabelDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Añadir Etiqueta',
              style: TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Selecciona el momento para tu etiqueta:'),
                const SizedBox(height: 20),
                // Seleccionar Dia
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text("Seleccionar Día"),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF1B1CB), foregroundColor: Colors.black),
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
                const SizedBox(height: 10),
                // Seleccionar Hora
                ElevatedButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: const Text("Seleccionar Hora"),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF1B1CB), foregroundColor: Colors.black),
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
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Guardar', style: TextStyle(color: Color(0xFFE94E77))),
              onPressed: () {
                // Aquí aniria la lògica per guardar l'etiqueta al Map o Firebase
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Etiqueta añadida correctamente'))
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
                      // Quan es clica un dia, mostrem les etiquetes d'aquell dia
                      _mostrarEtiquetesDelDia(date);
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