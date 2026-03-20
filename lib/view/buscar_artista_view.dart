import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flowvenue/services/spotifyServices.dart';

class BuscarArtistaView extends StatefulWidget {
  const BuscarArtistaView({super.key});

  @override
  State<BuscarArtistaView> createState() => _BuscarArtistaViewState();
}

class _BuscarArtistaViewState extends State<BuscarArtistaView> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _resultats = [];
  Map<String, String>? _artistaSeleccionat; // Guarda l'artista triat
  Timer? _debounce;
  bool _isLoading = false;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Esperem mig segon abans de cercar per no saturar l'API
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isNotEmpty) {
        setState(() => _isLoading = true);
        final resultats = await spotifyServices().searchArtists(query);
        setState(() {
          _resultats = resultats;
          _isLoading = false;
        });
      } else {
        setState(() {
          _resultats = [];
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
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
                  const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                        onPressed: () => Navigator.pop(context), // Botó enrere si no vol afegir res
                      ),
                    ),
                    Image.asset('assets/Logo_FlowVenue.png', height: 50),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // CERCADOR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: Color(0xFFE94E77)),
                  decoration: InputDecoration(
                    hintText: "Buscar artista en Spotify...",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // LLISTA DE RESULTATS
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _resultats.length,
                  itemBuilder: (context, index) {
                    final artista = _resultats[index];
                    final bool isSelected = _artistaSeleccionat == artista;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _artistaSeleccionat = artista; // Pintem de rosa la card seleccionada
                        });
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        color: isSelected ? const Color(0xFFD988B9) : Colors.white, // Fons rosa si està triat
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: artista['image']!.isNotEmpty
                                ? NetworkImage(artista['image']!)
                                : null,
                            backgroundColor: Colors.grey[300],
                            child: artista['image']!.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                          ),
                          title: Text(
                            artista['name']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              // Text blanc si és rosa el fons, text rosa si és blanc el fons
                              color: isSelected ? Colors.white : const Color(0xFFE94E77),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

                    // BOTÓ AFEGIR ARTISTA
                    if (_artistaSeleccionat != null)
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD988B9),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () {
                              // Retorna el nom de l'artista a la pantalla anterior
                              Navigator.pop(context, _artistaSeleccionat!['name']);
                            },
                            child: const Text("Añadir Artista", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      )
                  ],
              ),
            ),
        ),
    );
  }
}