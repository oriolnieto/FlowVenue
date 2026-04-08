import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:flowvenue/view/socialFeedView_view.dart';
import 'package:flowvenue/view/buscador_view.dart';
import 'package:flutter/material.dart';

import '../model/users_model.dart';
import '../services/db_services.dart';
import 'introduirCodi.dart';

class partyFeed_view extends StatefulWidget {
  final String urlLogo;
  final String idFesta;
  final Usuari usuari;


  const partyFeed_view({
    super.key,
    required this.idFesta,
    this.urlLogo = 'https://ibb.co/DPZmZpGw',
    required this.usuari,
  });

  @override
  _PartyFeedViewState createState() => _PartyFeedViewState();
}

class _PartyFeedViewState extends State<partyFeed_view> {
  final DbServices _dbServices = DbServices();

  Map<String, dynamic>? _cancoActual;
  String? _idCancoActual;
  final Set<String> _canconsReproduides = {};

  StreamSubscription? _playerStateSubscription;
  int _posicioActualMs = 0;
  int _duradaTotalMs = 1;
  bool _sEstaAcabant = false;

  @override
  void initState() {
    super.initState();
    _connectarASpotify();
  }

  Future<void> _connectarASpotify() async {
    try {
      var authenticationToken = await SpotifySdk.getAccessToken(
        clientId: "c23d9c5e2c574f2caef31066aa6a361e",
        redirectUrl: "flowvenue://callback",
        scope: "app-remote-control, user-modify-playback-state, playlist-read-private",
      );

      debugPrint("Token obtingut: $authenticationToken");

      bool result = await SpotifySdk.connectToSpotifyRemote(
        clientId: "c23d9c5e2c574f2caef31066aa6a361e",
        redirectUrl: "flowvenue://callback",
      );
      debugPrint("Connectat a Spotify: $result");

      _playerStateSubscription = SpotifySdk.subscribePlayerState().listen((state) {
        if (!mounted) return;

        setState(() {
          _posicioActualMs = state.playbackPosition;
          _duradaTotalMs = state.track?.duration ?? 1;
        });

        if (_posicioActualMs > 0 && _duradaTotalMs > 1) {
          int tempsRestant = _duradaTotalMs - _posicioActualMs;
          if (tempsRestant < 1500 && !_sEstaAcabant) {
            _sEstaAcabant = true;
            _passarALaSeguent();
          }
        }
      });
    } catch (e) {
      debugPrint("ERROR SPOTIFY: $e");
    }
  }

  void _passarALaSeguent() {
    setState(() {
      _cancoActual = null;
      _idCancoActual = null;
    });
  }

  void _iniciarReproduccio(String docId, Map<String, dynamic> canco) async {
    setState(() {
      _cancoActual = canco;
      _idCancoActual = docId;
      _canconsReproduides.add(docId);
      _sEstaAcabant = false;
    });

    String? uriSpotify = canco['uri'];
    if (uriSpotify != null && uriSpotify.isNotEmpty) {
      try {
        await SpotifySdk.play(spotifyUri: uriSpotify);
      } catch (e) {
        debugPrint("Error reproduint a Spotify: $e");
      }
    } else {
      debugPrint("Avís: Aquesta cançó no té URI de Spotify a Firebase");
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    SpotifySdk.pause();
    super.dispose();
  }

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

                    var documents = snapshot.data!.docs.toList();

                    documents.removeWhere((doc) => _canconsReproduides.contains(doc.id));

                    documents.sort((a, b) {
                      final dataA = a.data() as Map<String, dynamic>;
                      final dataB = b.data() as Map<String, dynamic>;
                      int votsA = dataA['votes'] ?? 0;
                      int votsB = dataB['votes'] ?? 0;
                      return votsB.compareTo(votsA);
                    });

                    if (_cancoActual == null && documents.isNotEmpty) {
                      final nextDoc = documents.first;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _iniciarReproduccio(nextDoc.id, nextDoc.data() as Map<String, dynamic>);
                      });
                    }

                    int itemCount = documents.length;
                    if (_cancoActual != null) itemCount += 1;

                    // Si tot està buit
                    if (itemCount == 0) {
                      return const Center(
                        child: Text(
                          "La pista està buida. Sol·licita una cançó!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        if (_cancoActual != null && index == 0) {
                          return Column(
                            children: [
                              _constructorPlayingNow(_cancoActual!),
                              const SizedBox(height: 20),
                            ],
                          );
                        }

                        int docIndex = _cancoActual != null ? index - 1 : index;
                        final doc = documents[docIndex];
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
              child: Image.asset(
                'assets/Logo_FlowVenue.png',
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
                MaterialPageRoute(builder: (context) => SocialFeedView(usuari: widget.usuari)), // passar usuari parametre
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _constructorPlayingNow(Map<String, dynamic> canco) {
    double progress = _duradaTotalMs > 0 ? (_posicioActualMs / _duradaTotalMs) : 0.0;
    if (progress > 1.0) progress = 1.0;
    if (progress < 0.0 || progress.isNaN) progress = 0.0;

    Duration tempsActual = Duration(milliseconds: _posicioActualMs);
    String formatActual = "${tempsActual.inMinutes.toString().padLeft(2, '0')}:${(tempsActual.inSeconds % 60).toString().padLeft(2, '0')}";

    Duration tempsTotal = Duration(milliseconds: _duradaTotalMs);
    String formatTotal = "${tempsTotal.inMinutes.toString().padLeft(2, '0')}:${(tempsTotal.inSeconds % 60).toString().padLeft(2, '0')}";

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
                  child: canco['cover'] != null && canco['cover'] != ''
                      ? Image.network(
                    canco['cover'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[800],
                    child: const Icon(Icons.music_note, color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          canco['title'] ?? 'Sense títol',
                          style: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis
                      ),
                      Text(
                          canco['artist'] ?? 'Desconegut',
                          style: const TextStyle(color: Colors.black54, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Slider(
                value: progress,
                onChanged: (v) {}, // buit per a que ningu pugui modificar el temps de la canço actual
                activeColor: Colors.pinkAccent,
                inactiveColor: Colors.black12
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                    "$formatActual / $formatTotal",
                    style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)
                )
              ],
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