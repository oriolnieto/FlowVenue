import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowvenue/view/socialFeedView_view.dart';
import 'package:flowvenue/view/buscador_view.dart';
import 'package:flutter/material.dart';

import '../services/db_services.dart';
import 'introduirCodi.dart';

class partyFeed_view extends StatefulWidget {
  final String urlLogo;
  final String idFesta;

  const partyFeed_view({
    super.key,
    required this.idFesta,
    this.urlLogo = 'https://h-chef.com/wp-content/uploads/2018/04/Razzmatazz.png',
  });

  @override
  _PartyFeedViewState createState() => _PartyFeedViewState();
}

class _PartyFeedViewState extends State<partyFeed_view> {
  final DbServices _dbServices = DbServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              _constructorHeader(),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _dbServices.escoltarVotacionsEnViu(widget.idFesta),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text("Error carregant les cançons", style: TextStyle(color: Colors.white)));
                    }

                    // Obtenim els documents
                    var documents = snapshot.data!.docs.toList();

                    // 2. ORDENACIÓ LOCAL PER EVITAR ERRORS AMB FIREBASE
                    documents.sort((a, b) {
                      final dataA = a.data() as Map<String, dynamic>;
                      final dataB = b.data() as Map<String, dynamic>;
                      int votsA = dataA['votes'] ?? 0;
                      int votsB = dataB['votes'] ?? 0;
                      return votsB.compareTo(votsA); // Ordena de més vots a menys vots
                    });

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: documents.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Column(
                            children: [
                              _constructorPlayingNow(),
                              const SizedBox(height: 20),
                            ],
                          );
                        }

                        final doc = documents[index - 1];
                        final cancoData = doc.data() as Map<String, dynamic>;

                        return _constructorCartaVotacio(doc.id, cancoData);
                      },
                    );
                  },
                ),
              ),

              _constructorBotoBottom(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "©2026 FlowVenue by Oriol&Jan",
                  style: TextStyle(color: Colors.white54, fontSize: 10),
                ),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Image.network(
                widget.urlLogo,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.local_activity, color: Colors.white),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.rss_feed, color: Colors.white),
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

  Widget _constructorPlayingNow() {
    return Card(
      color: Colors.white54,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    'https://i.scdn.co/image/ab67616d0000b273e8b066f70c206551210d902b',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[800],
                      child: const Icon(Icons.music_note, color: Colors.white, size: 40),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Boss", style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text("Lil Pump", style: TextStyle(color: Colors.black54, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            Slider(value: 0.4, onChanged: (v) {}, activeColor: Colors.pinkAccent, inactiveColor: Colors.black12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Text("00:47/2:14", style: TextStyle(color: Colors.black54, fontSize: 12))],
            )
          ],
        ),
      ),
    );
  }

  Widget _constructorCartaVotacio(String docId, Map<String, dynamic> songData) {
    return Card(
      color: Colors.white54,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: songData['cover'] != null && songData['cover'] != ''
              ? Image.network(songData['cover'], width: 50, height: 50, fit: BoxFit.cover)
              : Container(
            color: Colors.black12,
            width: 50,
            height: 50,
            child: const Icon(Icons.music_note, color: Colors.pinkAccent),
          ),
        ),
        title: Text(
          songData['title'] ?? 'Sense títol',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          songData['artist'] ?? 'Desconegut',
          style: const TextStyle(color: Colors.black54),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_upward_rounded, color: Colors.pink, size: 22),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                _dbServices.votarCanco(widget.idFesta, docId);
              },
            ),
            const SizedBox(width: 7),
            Text('${songData['votes'] ?? 0}', style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _constructorBotoBottom() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE94E77),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: () async {
          final novaCanco = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchView()),
          );

          if (novaCanco != null) {
            _dbServices.solLicitardCanco(widget.idFesta, novaCanco);
          }
        },
        child: const Center(
          child: Text(
            "Solicita una Canción!",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}