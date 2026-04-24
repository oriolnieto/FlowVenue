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
  RangeValues _filtrePreu = const RangeValues(0, 150);
  bool _haFiltratPreu = false;

  @override
  void initState() {
    super.initState();
    _carregarFestes();
    _carregarFestesGuardades();
  }

  Future<void> _carregarFestes() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('festes').get();
      setState(() {
        _totesLesFestes = snapshot.docs.map((doc) => {"id": doc.id, ...doc.data()}).toList();
        _festesFiltrades = List.from(_totesLesFestes);
      });
    } catch (e) { print("Error carregant dades: $e"); }
  }

  Future<void> _carregarFestesGuardades() async {
    if (widget.usuariActual == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('users').doc(widget.usuariActual!.userId).collection('agenda').get();
    setState(() { _festesGuardades = snapshot.docs.map((doc) => doc.id).toSet(); });
  }

  void _aplicarFiltres() {
    setState(() {
      _festesFiltrades = _totesLesFestes.where((f) {
        final nom = (f['nom'] ?? '').toString().toLowerCase();
        final artista = (f['artista'] ?? '').toString().toLowerCase();
        final textValid = _searchText.isEmpty || nom.contains(_searchText) || artista.contains(_searchText);

        bool dataValida = true;
        if (_filtreData != null && f['tipus'] != 'artista') {
          final rawData = f['fecha_evento'] ?? f['fechaEvento'];
          if (rawData != null) {
            DateTime dt = (rawData is Timestamp) ? rawData.toDate() : DateTime.parse(rawData.toString());
            dataValida = dt.day == _filtreData!.day && dt.month == _filtreData!.month && dt.year == _filtreData!.year;
          }
        }

        bool preuValid = true;
        if (_haFiltratPreu && f['tipus'] != 'artista') {
          double p = double.tryParse(f['precio']?.toString() ?? '0') ?? 0.0;
          preuValid = p >= _filtrePreu.start && p <= _filtrePreu.end;
        }
        return textValid && dataValida && preuValid;
      }).toList();
    });
  }

  Future<void> _toggleGuardar(Map<String, dynamic> item) async {
    if (widget.usuariActual == null) return;

    final String id = item['id'].toString();
    // Referència a la subcol·lecció 'agenda' de l'usuari
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.usuariActual!.userId)
        .collection('agenda')
        .doc(id);

    if (_festesGuardades.contains(id)) {
      // Si ja existeix, la borrem (desmarcar)
      await docRef.delete();
      setState(() => _festesGuardades.remove(id));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Eliminado de la agenda")),
      );
    } else {
      // SI NO EXISTEIX, LA GUARDEM (Bonus aplicat aquí)
      await docRef.set({
        'festaId': id,
        'titol': item['nom'] ?? 'Evento sin nombre',
        // Mantenim el format de data compatible amb el StreamBuilder de l'agenda
        'data': item['fecha_evento'] ?? Timestamp.now(),
        'tipus': item['tipus'] == 'artista' ? 'Concierto Artista' : 'Fiesta Guardada',
        'creatEn': FieldValue.serverTimestamp(), // Opcional: per saber quan es va guardar
      });

      setState(() => _festesGuardades.add(id));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Guardado en tu agenda!")),
      );
    }
  }

  void _mostrarDetalls(Map<String, dynamic> item) {
    bool esArtista = item['tipus'] == 'artista';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(item['nom'] ?? 'Detalles', style: const TextStyle(color: Color(0xFFE94E77), fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (esArtista) ...[
                _itemPopUp(Icons.audiotrack, "Spotify", item['artista'] ?? 'No disponible'),
                _itemPopUp(Icons.description, "Descripción", item['descripcio'] ?? 'Sin descripción'),
                const Divider(color: Color(0xFFE94E77), height: 30),
                const Align(alignment: Alignment.centerLeft, child: Text("Próximos Eventos:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE94E77)))),
                const SizedBox(height: 10),
                if (item['agenda'] != null)
                  ...(item['agenda'] as Map<String, dynamic>).entries.map((entry) {
                    List events = entry.value as List;
                    String dataISO = entry.key;
                    return Column(children: events.map((e) {
                      String subId = "${item['id']}_${e['nombre']}_$dataISO";
                      bool isSaved = _festesGuardades.contains(subId);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.event, size: 18, color: Colors.green),
                        title: Text(e['nombre'] ?? 'Evento', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: Text("${dataISO.split('T')[0]} - ${e['hora']}"),
                        trailing: IconButton(
                          icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, size: 20, color: isSaved ? Colors.black : Colors.grey),
                          onPressed: () { _toggleGuardar({'id': subId, 'nom': "${item['nom']}: ${e['nombre']}", 'fecha_evento': dataISO}); Navigator.pop(context); },
                        ),
                      );
                    }).toList());
                  }).toList()
                else const Text("No hay fechas próximas"),
              ] else ...[
                _itemPopUp(Icons.calendar_today, "Fecha", _formatarData(item['fecha_evento'])),
                _itemPopUp(Icons.location_on, "Ubicación", item['localizacion'] ?? 'No disponible'),
                _itemPopUp(Icons.euro, "Precio", "${item['precio'] ?? 0} €"),
              ],
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

  String _formatarData(dynamic d) {
    if (d == null) return 'Sin fecha';
    DateTime dt = (d is Timestamp) ? d.toDate() : DateTime.parse(d.toString());
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
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
                  ? const Center(child: Text("No se han encontrado resultados", style: TextStyle(color: Colors.white)))
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

  Widget _buildEventCard(Map<String, dynamic> item) {
    final bool estaGuardada = _festesGuardades.contains(item['id']);
    final bool esArtista = item['tipus'] == 'artista';
    return GestureDetector(
      onTap: () => _mostrarDetalls(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: esArtista ? Border.all(color: const Color(0xFFE94E77), width: 2) : null),
        child: Row(children: [
          Icon(esArtista ? Icons.star : Icons.music_note, color: const Color(0xFFE94E77)),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Text(item['nom'] ?? 'Evento', style: const TextStyle(fontWeight: FontWeight.bold)), if (esArtista) const Icon(Icons.verified, color: Colors.blue, size: 14)]),
            Text(esArtista ? "Artista disponible" : _formatarData(item['fecha_evento']), style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ])),
          IconButton(icon: Icon(estaGuardada ? Icons.bookmark : Icons.bookmark_border), onPressed: () => _toggleGuardar(item))
        ]),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.all(20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        Image.asset('assets/Logo_FlowVenue.png', height: 50),
        IconButton(
          icon: const Icon(Icons.calendar_month, color: Colors.white),
          onPressed: () {
            if (widget.usuariActual != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AgendaView(usuariActual: widget.usuariActual!),
                ),
              );
            } else {
              // Opcional: Mostrar un avís si no hi ha usuari
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Inicia sesión para ver tu agenda")),
              );
            }
          },
        )
      ],
    ),
  );
  Widget _buildSearchBar() => Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: TextField(onChanged: (v) { _searchText = v.toLowerCase(); _aplicarFiltres(); }, decoration: InputDecoration(hintText: "Busca evento o artista", filled: true, fillColor: Colors.white, prefixIcon: const Icon(Icons.search, color: Color(0xFFE94E77)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none))));
  Widget _buildFilterCarousel() => SizedBox(height: 40, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 20), children: [_fBtn(_filtreData != null ? "${_filtreData!.day}/${_filtreData!.month}" : "Fecha", Icons.event, _filtreData != null, () async { final p = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030)); if (p != null) { setState(() => _filtreData = p); _aplicarFiltres(); } }), _fBtn(_haFiltratPreu ? "${_filtrePreu.start.round()}€" : "Precio", Icons.euro, _haFiltratPreu, () {})]));
  Widget _fBtn(String t, IconData i, bool a, VoidCallback o) => Container(margin: const EdgeInsets.only(right: 10), child: ElevatedButton.icon(onPressed: o, icon: Icon(i, size: 16), label: Text(t), style: ElevatedButton.styleFrom(backgroundColor: a ? const Color(0xFFD988B9) : Colors.white70, foregroundColor: a ? Colors.white : Colors.black)));
}