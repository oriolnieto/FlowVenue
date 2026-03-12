import 'package:flutter/material.dart';

class buscador_festa_view extends StatefulWidget {
  const buscador_festa_view({super.key});

  @override
  State<buscador_festa_view> createState() => _BuscadorFestaViewState();
}

class _BuscadorFestaViewState extends State<buscador_festa_view> {
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

              // Carrusel de filtres horitzontal
              _buildFilterCarousel(),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  children: [
                    _buildSectionTitle("Visto Recientemente"),
                    _buildEventCard(
                      "Mandanga Meme Party",
                      "Jue, 12 mar",
                      "Razzmatazz 4",
                    ),
                    _buildEventCard(
                      "Candy X OTTO",
                      "Jue, 12 mar",
                      "Otto Zutz Barcelona",
                    ),
                    const SizedBox(height: 25),
                    _buildSectionTitle("Popular en FlowVenue"),
                    _buildEventCard(
                      "Festa Intercampus UdL",
                      "Jue, 5 mar",
                      "Campus de Cappont",
                    ),
                    _buildEventCard(
                      "Alvama Ice",
                      "DJ influyente",
                      "Panorama urbano",
                    ),
                  ],
                ),
              ),

              // Footer corporatiu
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    "©2026 FlowVenue by Oriol&Jan",
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                  ),
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
          Image.asset(
            'assets/Logo_FlowVenue.png',
            height: 400,
            width: 350,
          ),
          const SizedBox(width: 40), // Equilibri per al botó de tornada
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const TextField(
          style: TextStyle(color: Colors.black87),
          decoration: InputDecoration(
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
    final filters = ["Fecha", "Precio", "Cerca de Mi", "Más Filtros"];
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1B1CB),
                foregroundColor: const Color(0xFFE94E77),
                elevation: 0,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onPressed: () {},
              child: Text(
                filters[index],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Mètode corregit sense demanar IconData per paràmetre
  Widget _buildEventCard(String name, String date, String location) {
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
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            // He posat una icona d'imatge genèrica per defecte
            child: const Icon(Icons.image, color: Color(0xFFE94E77), size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                Text(location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.bookmark_border, color: Colors.black54),
        ],
      ),
    );
  }
}