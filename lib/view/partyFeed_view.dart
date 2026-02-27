import 'package:flutter/material.dart';

class partyFeed_view extends StatefulWidget {
  final String urlLogo;
  partyFeed_view ({
    this.urlLogo = 'https://h-chef.com/wp-content/uploads/2018/04/Razzmatazz.png' });

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      body: Container(
        // Fons degradat segons la canço
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE94E77), Color(0xFF6A1B9A), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _constructorHeader(),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _constructorPlayingNow(),
                    SizedBox(height: 20),
                    _constructorCartaVotacio(
                        "HER", "Chase Atlantic", Color(0xFF9C27B0), "7"),
                    _constructorCartaVotacio(
                        "Telfon", "RAF Camora", Color(0xFF1A1A1A), "1"),
                    _constructorCartaVotacio(
                        "GOTTI", "6ix9ine", Colors.orangeAccent, "1",
                        isGradient: true),

                  ],
                ),
              ),

              _constructorBotoBottom(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("©2026 FlowVenue by Oriol&Jan",
                    style: TextStyle(color: Colors.white54, fontSize: 10)),
              )
            ],
          ),
        ),
      ),
    );
  }
  
  // Canço actual amb la seva paleta de colors
  
  Widget _constructorPlayingNow() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), 
        borderRadius: BorderRadius.circular(25),
      ),
      
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network('https://images.genius.com/f9b...',width: 80, height: 80, fit: BoxFit.cover),

              ),
              SizedBox(width: 15),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Boss", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("Lil Pump", style: TextStyle(color: Colors.white70, fontSize: 16)),
                    ],

                  ),
              ),
            ],
          ),

          Slider(value: 0.4, onChanged: (v) {}, activeColor: Colors.white, inactiveColor: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Text("00:47/2:14", style: TextStyle(color: Colors.white70, fontSize: 12))],
    
    )
          )




        ],
      )
      
      
      
      
      
    )
  }
  }


