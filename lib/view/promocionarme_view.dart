import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class PromocionarmeView extends StatefulWidget {
  const PromocionarmeView({super.key});

  @override
  State<PromocionarmeView> createState() => _PromocionarmeViewState();
}

class _PromocionarmeViewState extends State<PromocionarmeView> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcioController = TextEditingController();

  // Aquí guardarem tots els dies que l'artista marqui com a disponibles/ocupats
  final Map<DateTime , List<String>> _eventsPerDia = {};
  DateTime _focusedDay = DateTime.now();

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcioController.dispose();
    super.dispose();
  }

  // Funció auxiliar per treure les hores/minuts i comparar només els dies
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // --- FUNCIÓ QUE MOSTRA EL POP-UP ---
  void _mostrarPopUpEventos(DateTime diaSeleccionat) {
    DateTime normalizedDay = _normalizeDate(diaSeleccionat);
    TextEditingController _nuevoEventoController = TextEditingController();

    // Controla si estem mostrant el camp per escriure un nou esdeveniment
    bool isAdding = false;

    showDialog(
      context: context,
      builder: (context) {
        // Fem servir StatefulBuilder perquè el pop-up es pugui actualitzar a si mateix sense tancar-se
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // Agafem els esdeveniments d'aquest dia o una llista buida
            List<String> eventosDelDia = _eventsPerDia[normalizedDay] ?? [];

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                "Eventos - ${diaSeleccionat.day}/${diaSeleccionat.month}/${diaSeleccionat.year}",
                style: const TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Si no hi ha res i no estem afegint
                    if (eventosDelDia.isEmpty && !isAdding)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text("Día libre. No hay eventos.", style: TextStyle(color: Colors.grey)),
                      ),

                    // Llista d'Etiquetes (Esdeveniments afegits)
                    if (eventosDelDia.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: eventosDelDia.length,
                        itemBuilder: (context, index) {
                          return Card(
                            color: const Color(0xFFF1B1CB),
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: ListTile(
                              title: Text(
                                  eventosDelDia[index],
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
                              ),
                              subtitle: Text(
                                  "${diaSeleccionat.day}/${diaSeleccionat.month}/${diaSeleccionat.year}",
                                  style: const TextStyle(color: Colors.white70)
                              ),
                              trailing: IconButton( // Botó opcional per esborrar l'event
                                icon: const Icon(Icons.delete, color: Colors.white),
                                onPressed: () {
                                  setStateDialog(() {
                                    _eventsPerDia[normalizedDay]!.removeAt(index);
                                    if (_eventsPerDia[normalizedDay]!.isEmpty) {
                                      _eventsPerDia.remove(normalizedDay);
                                    }
                                  });
                                  setState(() {}); // Actualitza el calendari de sota
                                },
                              ),
                            ),
                          );
                        },
                      ),

                    // Camp de text que apareix quan toquem "Añadir Evento"
                    if (isAdding)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: TextField(
                          controller: _nuevoEventoController,
                          style: const TextStyle(color: Color(0xFFE94E77)),
                          decoration: InputDecoration(
                            hintText: "Escribe el nombre...",
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                            suffixIcon: IconButton( // Botó per confirmar l'afegit
                              icon: const Icon(Icons.check_circle, color: Color(0xFFE94E77), size: 30),
                              onPressed: () {
                                if (_nuevoEventoController.text.isNotEmpty) {
                                  setStateDialog(() {
                                    if (_eventsPerDia[normalizedDay] == null) {
                                      _eventsPerDia[normalizedDay] = [];
                                    }
                                    _eventsPerDia[normalizedDay]!.add(_nuevoEventoController.text);
                                    isAdding = false;
                                    _nuevoEventoController.clear();
                                  });
                                  // Actualitzem la pantalla principal perquè el calendari es pinti rosa
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                if (!isAdding)
                  TextButton(
                    onPressed: () {
                      setStateDialog(() {
                        isAdding = true; // Activa el camp de text
                      });
                    },
                    child: const Text("+ Añadir Evento", style: TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold)),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cerrar", style: TextStyle(color: Colors.black54)),
                ),
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
                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    "Perfil de Artista",
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),

                // CAMP NOM
                _buildTextField("Nombre del Artista", _nombreController),
                const SizedBox(height: 15),

                // CAMP DESCRIPCIÓ
                _buildTextField("Descripción", _descripcioController, maxLines: 4),
                const SizedBox(height: 25),

                // TÍTOL AGENDA
                const Text(
                  "Agenda de Disponibilidad",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),

                // CALENDARI MULTI-DATA
                _buildCalendari(),

                const SizedBox(height: 40),

                // BOTÓ GUARDAR
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD988B9), // Rosa de l'app
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                    ),
                    onPressed: () {
                      print("Nom: ${_nombreController.text}");
                      print("Descripció: ${_descripcioController.text}");
                      // CORREGIT: Imprimim el mapa en lloc del Set
                      print("Events guardats: $_eventsPerDia");

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Perfil de artista actualizado correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    },

                    child: const Text(
                      "Guardar y Promocionarme",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
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
        const SizedBox(width: 40), // Per balancejar el botó de tirar enrere
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendari() {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(10),
        child: TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 365)), // Permet fins a 1 any vista
          focusedDay: _focusedDay,

          // Aquí li diem quins dies han d'aparèixer com a "seleccionats"
          selectedDayPredicate: (day) {
            DateTime normalizedDay = _normalizeDate(day);
            return _eventsPerDia.containsKey(normalizedDay) && _eventsPerDia[normalizedDay]!.isNotEmpty;
          },

          // Què passa quan l'usuari clica un dia
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _focusedDay = focusedDay;


            });
            _mostrarPopUpEventos(selectedDay);
            },

          // ESTILS DEL CALENDARI
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Color(0xFFE94E77), // EL COLOR ROSA
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Color(0xFFF1B1CB), // Rosa més fluixet pel dia d'avui
              shape: BoxShape.circle,
            ),
            defaultTextStyle: TextStyle(color: Colors.black),
            weekendTextStyle: TextStyle(color: Colors.black54),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold, fontSize: 18),
            leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFFE94E77)),
            rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFFE94E77)),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            weekendStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ),
    );
  }
}