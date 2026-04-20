import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowvenue/model/users_model.dart';
import 'agenda_view.dart';

class buscador_festa_view extends StatefulWidget {
  final Usuari? usuariActual;
  const buscador_festa_view({super.key, this.usuariActual});

  @override
  State<buscador_festa_view> createState() => _BuscadorFestaViewState();
}

class _BuscadorFestaViewState extends State<buscador_festa_view> {
  List<Map<String, dynamic>> _totesLesFestes = [];
  List<Map<String, dynamic>> _festesFiltrades = [];
  Set<String> _festesGuardades = {};

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

  // --- CARREGA DE DADES ---
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

  // --- LÒGICA DE FILTRAT ---
  void _aplicarFiltres() {
    setState(() {
      _festesFiltrades = _totesLesFestes.where((festa) {
        // Cercador per text
        final nom = (festa['nom'] ?? festa['name'] ?? '').toString().toLowerCase();
        final artista = (festa['artista'] ?? '').toString().toLowerCase();
        final cercaValida = _searchText.isEmpty || nom.contains(_searchText) || artista.contains(_searchText);

        // Filtre per Data
        bool dataValida = true;
        final dataFirebase = festa['fecha_evento'] ?? festa['fechaEvento'];
        if (_filtreData != null && dataFirebase != null) {
          DateTime dataFesta = (dataFirebase is Timestamp) ? dataFirebase.toDate() : DateTime.parse(dataFirebase.toString());
          dataValida = dataFesta.year == _filtreData!.year && dataFesta.month == _filtreData!.month && dataFesta.day == _filtreData!.day;
        }

        // Filtre per Preu
        bool preuValid = true;
        if (_haFiltratPreu) {
          final preu = (festa['precio'] ?? festa['preu'] ?? 0).toDouble();
          preuValid = preu >= _filtrePreu.start && preu <= _filtrePreu.end;
        }

        return cercaValida && dataValida && preuValid;
      }).toList();
    });
  }

  // --- DIÀLEGS DE FILTRE ---
  Future<void> _mostrarFiltreData() async {
    final DateTime? p = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFFE94E77))),
        child: child!,
      ),
    );
    if (p != null) { setState(() => _filtreData = p); _aplicarFiltres(); }
  }

  Future<void> _mostrarFiltrePreu() async {
    RangeValues tempRange = _filtrePreu;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Rango de Precio (€)", style: TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("${tempRange.start.round()}€ - ${tempRange.end.round()}€", style: const TextStyle(fontWeight: FontWeight.bold)),
              RangeSlider(
                values: tempRange,
                min: 0, max: 150, divisions: 30,
                activeColor: const Color(0xFFE94E77),
                onChanged: (values) => setStateDialog(() => tempRange = values),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () {
              setState(() { _haFiltratPreu = false; _filtrePreu = const RangeValues(0, 100); _aplicarFiltres(); });
              Navigator.pop(context);
            }, child: const Text("Borrar", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD988B9)),
              onPressed: () {
                setState(() { _haFiltratPreu = true; _filtrePreu = tempRange; _aplicarFiltres(); });
                Navigator.pop(context);
              },
              child: const Text("Aplicar", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // --- POP-UP DETALLS ---
  void _mostrarDetallsFesta(Map<String, dynamic> festa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(festa['nom'] ?? 'Detalles', style: const TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _itemPopUp(Icons.calendar_today, "Fecha", _formatarData(festa['fecha_evento'])),
              _itemPopUp(Icons.access_time, "Horario", "${festa['hora_inicio'] ?? '--'} - ${festa['hora_fin'] ?? '--'}"),
              _itemPopUp(Icons.location_on, "Ubicación", festa['localizacion'] ?? 'No disponible'),
              _itemPopUp(Icons.euro, "Precio", "${festa['precio'] ?? 0} €"),
              _itemPopUp(Icons.person, "Artista", festa['artista'] ?? 'No especificado'),
              _itemPopUp(Icons.music_note, "Estilos", (festa['tipoFesta'] is List) ? (festa['tipoFesta'] as List).join(", ") : 'Varios'),
              _itemPopUp(Icons.vpn_key, "Código", "${festa['codiAcces'] ?? 'Privado'}"),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar"))],
      ),
    );
  }

  Widget _itemPopUp(IconData icon, String t, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      Icon(icon, size: 20, color: const Color(0xFFE94E77)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        Text(v, style: const TextStyle(fontSize: 14)),
      ])),
    ]),
  );

  String _formatarData(dynamic data) {
    if (data == null) return 'Sin fecha';
    DateTime dt = (data is Timestamp) ? data.toDate() : DateTime.parse(data.toString());
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }

  Future<void> _toggleGuardarFesta(Map<String, dynamic> festa) async {
    if (widget.usuariActual == null) return;
    final String id = festa['id'];
    final docRef = FirebaseFirestore.instance.collection('users').doc(widget.usuariActual!.userId).collection('agenda').doc(id);
    setState(() {
      if (_festesGuardades.contains(id)) { _festesGuardades.remove(id); docRef.delete(); }
      else { _festesGuardades.add(id); docRef.set({'festaId': id, 'nom': festa['nom'], 'data': festa['fecha_evento']}); }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/Background_App.png'), fit: BoxFit.cover)),
        child: SafeArea(
          child: Column(children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 15),
            _buildFilterCarousel(),
            Expanded(
              child: _festesFiltrades.isEmpty
                  ? const Center(child: Text("No hay fiestas disponibles", style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _festesFiltrades.length,
                itemBuilder: (context, index) => _buildEventCard(_festesFiltrades[index]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> festa) {
    final bool estaGuardada = _festesGuardades.contains(festa['id']);
    return GestureDetector(
      onTap: () => _mostrarDetallsFesta(festa),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))]
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(festa['nom'] ?? 'Evento', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 5),
            Row(children: [
              const Icon(Icons.calendar_today, size: 12, color: Color(0xFFE94E77)),
              const SizedBox(width: 5),
              Text("${_formatarData(festa['fecha_evento'])}  •  ${festa['hora_inicio'] ?? '00:00'}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ]),
            Text(festa['localizacion'] ?? 'Sin ubicación', style: const TextStyle(color: Colors.black54, fontSize: 12)),
          ])),
          Text("${festa['precio'] ?? 0}€", style: const TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold)),
          IconButton(
            icon: Icon(estaGuardada ? Icons.bookmark : Icons.bookmark_border, color: estaGuardada ? Colors.black : Colors.grey),
            onPressed: () => _toggleGuardarFesta(festa),
          )
        ]),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.all(20),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      Image.asset('assets/Logo_FlowVenue.png', height: 50),
      IconButton(icon: const Icon(Icons.calendar_month, color: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AgendaView()))),
    ]),
  );

  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: TextField(
      onChanged: (v) { _searchText = v.toLowerCase(); _aplicarFiltres(); },
      decoration: InputDecoration(
        hintText: "Busca evento o artista",
        filled: true, fillColor: Colors.white,
        prefixIcon: const Icon(Icons.search, color: Color(0xFFE94E77)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      ),
    ),
  );

  Widget _buildFilterCarousel() => SizedBox(
    height: 40,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20),
      children: [
        _fBtn(_filtreData != null ? "${_filtreData!.day}/${_filtreData!.month}" : "Fecha", Icons.event, _filtreData != null, _mostrarFiltreData),
        _fBtn(_haFiltratPreu ? "${_filtrePreu.start.round()}-${_filtrePreu.end.round()}€" : "Precio", Icons.euro, _haFiltratPreu, _mostrarFiltrePreu),
      ],
    ),
  );

  Widget _fBtn(String t, IconData i, bool a, VoidCallback o) => Container(
    margin: const EdgeInsets.only(right: 10),
    child: ElevatedButton.icon(
      onPressed: o, icon: Icon(i, size: 16), label: Text(t),
      style: ElevatedButton.styleFrom(backgroundColor: a ? const Color(0xFFD988B9) : Colors.white70, foregroundColor: a ? Colors.white : Colors.black87),
    ),
  );
}