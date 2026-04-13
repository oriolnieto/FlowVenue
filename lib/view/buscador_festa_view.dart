import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowvenue/model/users_model.dart';

import 'agenda_view.dart';

class buscador_festa_view extends StatefulWidget {
  final Usuari? usuariActual; // Afegit per saber si està registrat
  const buscador_festa_view({super.key, this.usuariActual});

  @override
  State<buscador_festa_view> createState() => _BuscadorFestaViewState();
}

class _BuscadorFestaViewState extends State<buscador_festa_view> {
  // Llistes per gestionar les dades
  List<Map<String, dynamic>> _totesLesFestes = [];
  List<Map<String, dynamic>> _festesFiltrades = [];
  Set<String> _festesGuardades = {}; // Per controlar les festes desades (Icona Negra)

  // Variables dels filtres
  String _searchText = "";
  DateTime? _filtreData;
  RangeValues _filtrePreu = const RangeValues(0, 100);
  bool _haFiltratPreu = false;

  @override
  void initState() {
    super.initState();
    _carregarFestes();
    _carregarFestesGuardades();
  }

  // 1. OBTENIR FESTES DE FIREBASE
  Future<void> _carregarFestes() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('festes').get();
      setState(() {
        _totesLesFestes = snapshot.docs.map((doc) {
          return {"id": doc.id, ...doc.data()};
        }).toList();
        _festesFiltrades = List.from(_totesLesFestes);
      });
    } catch (e) {
      print("Error carregant festes: $e");
    }
  }

  // 2. OBTENIR LES FESTES JA GUARDADES PER L'USUARI
  Future<void> _carregarFestesGuardades() async {
    if (widget.usuariActual == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.usuariActual!.userId)
          .collection('agenda')
          .get();

      setState(() {
        _festesGuardades = snapshot.docs.map((doc) => doc.id).toSet();
      });
    } catch (e) {
      print("Error carregant agenda: $e");
    }
  }

  // 3. FUNCIÓ PER GUARDAR / ELIMINAR DE L'AGENDA
  Future<void> _toggleGuardarFesta(Map<String, dynamic> festa) async {
    if (widget.usuariActual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para guardar eventos.'), backgroundColor: Colors.red),
      );
      return;
    }

    final String festaId = festa['id'];
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.usuariActual!.userId)
        .collection('agenda')
        .doc(festaId);

    setState(() {
      if (_festesGuardades.contains(festaId)) {
        _festesGuardades.remove(festaId);
        docRef.delete(); // Esborrem de Firebase
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento eliminado de tu agenda.')),
        );
      } else {
        _festesGuardades.add(festaId);
        // Guardem a Firebase per sortir a l'Agenda
        docRef.set({
          'festaId': festaId,
          'nom': festa['nom'] ?? 'Sense nom',
          'data': festa['data'],
          'guardatEl': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Evento guardado en tu agenda!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
        );
      }
    });
  }

  // 4. LÒGICA DE FILTRAT
  void _aplicarFiltres() {
    setState(() {
      _festesFiltrades = _totesLesFestes.where((festa) {
        // Filtre per text (Buscador)
        final nom = (festa['nom'] ?? festa['name'] ?? '').toString().toLowerCase();
        final artista = (festa['artista'] ?? '').toString().toLowerCase();
        final cercaValida = _searchText.isEmpty || nom.contains(_searchText) || artista.contains(_searchText);

        // Filtre per Data
        bool dataValida = true;
        final dataFirebase = festa['fecha_evento'] ?? festa['fechaEvento'] ?? festa['data'] ?? festa['date'];


        if (_filtreData != null && dataFirebase != null) {
          DateTime dataFesta;
          if (dataFirebase is Timestamp) {
            dataFesta = dataFirebase.toDate();
          } else {
            dataFesta = DateTime.parse(dataFirebase.toString());
          }
          dataValida = dataFesta.year == _filtreData!.year &&
              dataFesta.month == _filtreData!.month &&
              dataFesta.day == _filtreData!.day;
        }

        // Filtre per Preu
        bool preuValid = true;
        if (_haFiltratPreu) {
          final preu = (festa['preu'] ?? festa['price'] ?? 0).toDouble();
          preuValid = preu >= _filtrePreu.start && preu <= _filtrePreu.end;
        }

        return cercaValida && dataValida && preuValid;
      }).toList();
    });
  }

  // POP-UPS DE FILTRES
  Future<void> _mostrarFiltreData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _filtreData ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE94E77), // Color Rosa
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _filtreData = picked);
      _aplicarFiltres();
    }
  }

  Future<void> _mostrarFiltrePreu() async {
    RangeValues tempRange = _filtrePreu;
    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setStateDialog) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text("Rango de Precio (€)", style: TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold)),
                  content: SizedBox(
                    height: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${tempRange.start.round()}€  -  ${tempRange.end.round()}€", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        RangeSlider(
                          values: tempRange,
                          min: 0,
                          max: 150,
                          divisions: 30,
                          activeColor: const Color(0xFFE94E77),
                          inactiveColor: const Color(0xFFF1B1CB),
                          onChanged: (RangeValues values) {
                            setStateDialog(() => tempRange = values);
                          },
                        ),
                      ],
                    ),
                  ),

                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _haFiltratPreu = false;
                          _filtrePreu = const RangeValues(0, 100);
                          _aplicarFiltres();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Borrar", style: TextStyle(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD988B9)),
                      onPressed: () {
                        setState(() {
                          _haFiltratPreu = true;
                          _filtrePreu = tempRange;
                          _aplicarFiltres();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Aplicar", style: TextStyle(color: Colors.white)),
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
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  _buildHeader(),
              _buildSearchBar(),
              const SizedBox(height: 15),

              // Carrusel de filtres
              _buildFilterCarousel(),

              Expanded(
                child: _totesLesFestes.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFE94E77)))
                    : _festesFiltrades.isEmpty
                    ? const Center(child: Text("No se han encontrado fiestas.", style: TextStyle(color: Colors.white, fontSize: 16)))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: _festesFiltrades.length,
                  itemBuilder: (context, index) {
                    return _buildEventCard(_festesFiltrades[index]);
                  },
                ),
              ),

                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text("©2026 FlowVenue by Oriol&Jan", style: TextStyle(color: Colors.white54, fontSize: 10)),
                      ),
                    )
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
            radius: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Image.asset('assets/Logo_FlowVenue.png', height: 60, fit: BoxFit.contain),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 20,
            child: IconButton(
              icon: const Icon(Icons.calendar_month, color: Colors.black, size: 20),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AgendaView()));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: TextField(
          style: const TextStyle(color: Colors.black87),
          onChanged: (value) {
            _searchText = value.toLowerCase();
            _aplicarFiltres();
          },
          decoration: const InputDecoration(
            hintText: "Busca un evento o artista",
            hintStyle: TextStyle(color: Color(0xFFE94E77)),
            prefixIcon: Icon(Icons.search, color: Color(0xFFE94E77)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterCarousel() {

    return SizedBox(
      height: 35,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        children: [
          _buildFilterButton(
            text: _filtreData != null ? "${_filtreData!.day}/${_filtreData!.month}" : "Fecha",
            icon: Icons.calendar_today,
            isActive: _filtreData != null,
            onPressed: _mostrarFiltreData,
          ),
          _buildFilterButton(
            text: _haFiltratPreu ? "${_filtrePreu.start.round()}-${_filtrePreu.end.round()}€" : "Precio",
            icon: Icons.attach_money,
            isActive: _haFiltratPreu,
            onPressed: _mostrarFiltrePreu,
          ),
          // El de localització es queda visual per disseny, pots fer-lo funcional més endavant
          _buildFilterButton(
            text: "Cerca de Mi",
            icon: Icons.location_on,
            isActive: false,
            onPressed: () {},
          ),
          if (_filtreData != null || _haFiltratPreu)
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _filtreData = null;
                    _haFiltratPreu = false;
                    _aplicarFiltres();
                  });
                },
              ),
            )
        ],
      ),
    );
  }

  Widget _buildFilterButton({required String text, required IconData icon, required bool isActive, required VoidCallback onPressed}) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? const Color(0xFFD988B9) : const Color(0xFFF1B1CB),
          foregroundColor: isActive ? Colors.white : const Color(0xFFE94E77),
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 15),
        ),
        icon: Icon(icon, size: 16),
        label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> festa) {


    print("🔍 DADES REBUDES DE FIREBASE: $festa");


    final String id = festa['id'];
    final String nom = festa['nom'] ?? festa['name'] ?? 'Sense Nom';
    final String lloc = festa['localizacion'] ?? festa['lloc'] ?? festa['location'] ?? festa['ubicacion'] ?? 'Sense lloc';
    final dataFirebase = festa['fecha_evento'] ?? festa['fechaEvento'] ?? festa['fecha'] ?? festa['data'] ?? festa['date'];
    final String imatgeUrl = festa['imatge'] ?? festa['imageUrl'] ?? '';

    final rawPreu = festa['precio'] ?? festa['preu'];
    final double preu = rawPreu != null ? double.tryParse(rawPreu.toString()) ?? 0.0 : 0.0;

    // Transformació de la Data per tenir Dia i Hora
    String dataFormatada = 'Sense data';
    String horaFormatada = '';



    if (dataFirebase != null) {
      try {
        DateTime dataFesta;
        if (dataFirebase is Timestamp) {
          dataFesta = dataFirebase.toDate();
        } else {
          dataFesta = DateTime.parse(dataFirebase.toString());
        }
        dataFormatada = "${dataFesta.day.toString().padLeft(2, '0')}/${dataFesta.month.toString().padLeft(2, '0')}/${dataFesta.year}";
        horaFormatada = "${dataFesta.hour.toString().padLeft(2, '0')}:${dataFesta.minute.toString().padLeft(2, '0')}";
      } catch (e) {
        dataFormatada = dataFirebase.toString(); // Si ve com un text pla en comptes de Timestamp
      }
    }

    final bool estaGuardada = _festesGuardades.contains(id);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
        // Imatge
        Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          image: imatgeUrl.isNotEmpty
              ? DecorationImage(image: NetworkImage(imatgeUrl), fit: BoxFit.cover)
              : null,
        ),
        child: imatgeUrl.isEmpty
            ? const Icon(Icons.music_note, color: Color(0xFFE94E77), size: 30)
            : null,
      ),

          const SizedBox(width: 15),
          // Informació
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nom,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("$dataFormatada  $horaFormatada", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(lloc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      preu == 0 ? "GRATIS" : "${preu.toStringAsFixed(2)}€",
                      style: const TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Botó Guardar
          IconButton(
            icon: Icon(
              estaGuardada ? Icons.bookmark : Icons.bookmark_border,
              color: estaGuardada ? Colors.black : Colors.black54,
              size: 28,
            ),
            onPressed: () => _toggleGuardarFesta(festa),
          ),
        ],
      ),
    );
  }
}



