import 'package:flowvenue/view/socialFeedView_view.dart';
import 'package:flutter/material.dart';

import 'introduirCodi.dart';

class partyFeed_view extends StatefulWidget {
  final String urlLogo;

 const partyFeed_view({
   super.key,
    this.urlLogo = 'https://h-chef.com/wp-content/uploads/2018/04/Razzmatazz.png' });

  @override
  _PartyFeedViewState createState() => _PartyFeedViewState();
}

class _PartyFeedViewState extends State<partyFeed_view> {

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        // Fons degradat segons la canço
        decoration: BoxDecoration(

          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE94E77), Color(0xFF6A1B9A), Color(0xFF000000)],
          ),
          image: const DecorationImage(
            image: AssetImage('assets/Background_App.png'),
            fit: BoxFit.cover,
            // opacity: 0.4, // Descomenta aquesta línia si vols barrejar la imatge amb el gradient
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

  Widget _constructorHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const introduirCodi()),

              );
            },
          ),

          // Imatge dinàmica del logo de la discoteca
          Image.network(
            widget.urlLogo,
            height: 40,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: Colors.white),
          ),
          IconButton(
              icon: Icon(Icons.rss_feed, color: Colors.white),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SocialFeedView()),
                );
              },
          ),
        ],
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
                child: Image.network(
                    'https://images.genius.com/f9b...', width: 80,
                    height: 80,
                    fit: BoxFit.cover),

              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Boss", style: TextStyle(color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                    Text("Lil Pump",
                        style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],

                ),
              ),
            ],
          ),

          Slider(value: 0.4,
              onChanged: (v) {},
              activeColor: Colors.white,
              inactiveColor: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Text("00:47/2:14", style: TextStyle(color: Colors.white70, fontSize: 12))],
    )
        ],
      ),
    );
  }

  Widget _constructorCartaVotacio(String title, String artist, Color color, String votes, {bool isGradient = false})  {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isGradient ? null : color.withOpacity(0.8),
        gradient: isGradient ? LinearGradient(colors: [Colors.orange, Colors.pink]) : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(color: Colors.grey[800], width: 50, height: 50, child: Icon(Icons.music_note, color: Colors.white24)),

        ),
        title: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold )),
        subtitle: Text(artist, style: TextStyle(color: Colors.white70)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(votes, style: TextStyle(color: Colors.white)),
      
          ],
        ),
      )
    );      
  }
  
  Widget _constructorBotoBottom() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFE94E77),
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(vertical: 15),

        ),
        onPressed: () {},
        child: Center(child: Text("Solicita una Canción!", style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
      ),
    );
  }




  }

  
  
  
