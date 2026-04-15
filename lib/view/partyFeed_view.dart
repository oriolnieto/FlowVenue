import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowvenue/view/socialFeedView_view.dart';
import 'package:flowvenue/view/buscador_view.dart';
import 'package:flutter/material.dart';

import '../model/users_model.dart';
import '../services/db_services.dart';
import '../services/spotifyServices.dart';
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
  final spotifyServices _spotifyService = spotifyServices();

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
      await _spotifyService.getAuthToken();
      bool result = await _spotifyService.connect();

      if (result) {
        _playerStateSubscription = _spotifyService.playerStateStream.listen((state) {
          if (!mounted) return;

          setState(() {
            _posicioActualMs = state.playbackPosition;
            _duradaTotalMs = state.track?.duration ?? 1;
          });

          if (_posicioActualMs > 0 && _duradaTotalMs > 1) {
            int tempsRestant = _duradaTotalMs - _posicioActualMs;
            if (tempsRestant < 2000 && !_sEstaAcabant) {
              _sEstaAcabant = true;
              _passarALaSeguent();
            }
          }
        });
      }
    } catch (e) {
      debugPrint("ERROR SPOTIFY: $e");
    }
  }

  void _passarALaSeguent() async {
    String? idPerEliminar = _idCancoActual;

    setState(() {
      _cancoActual = null;
      _idCancoActual = null;
      _sEstaAcabant = false;
    });

    if (idPerEliminar != null) {
      await _dbServices.eliminarCanco(widget.idFesta, idPerEliminar);
    }
  }

  void _iniciarReproduccio(String docId, Map<String, dynamic> canco) async {
    if (_idCancoActual == docId) return;

    setState(() {
      _cancoActual = canco;
      _idCancoActual = docId;
      _canconsReproduides.add(docId);
      _sEstaAcabant = false;
    });

    String? uriSpotify = canco['uri'];
    if (uriSpotify != null && uriSpotify.isNotEmpty) {
      try {
        await _spotifyService.play(uriSpotify);
        await Future.delayed(const Duration(milliseconds: 600));
        await _spotifyService.resume();
      } catch (e) {
        debugPrint("Error reproduint: $e");
      }
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _spotifyService.pause();
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

                    var documents = snapshot.data?.docs.toList() ?? [];

                    if (_cancoActual == null && documents.isNotEmpty) {
                      documents.sort((a, b) {
                        final dataA = a.data() as Map<String, dynamic>;
                        final dataB = b.data() as Map<String, dynamic>;
                        return (dataB['votes'] ?? 0).compareTo(dataA['votes'] ?? 0);
                      });

                      final nextDoc = documents.first;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _iniciarReproduccio(nextDoc.id, nextDoc.data() as Map<String, dynamic>);
                      });
                    }

                    Map<String, dynamic>? dadesPlayingNow;
                    List<QueryDocumentSnapshot> llistaVotacions = [];

                    for (var doc in documents) {
                      if (doc.id == _idCancoActual) {
                        dadesPlayingNow = doc.data() as Map<String, dynamic>;
                      } else {
                        llistaVotacions.add(doc);
                      }
                    }

                    llistaVotacions.sort((a, b) {
                      final dataA = a.data() as Map<String, dynamic>;
                      final dataB = b.data() as Map<String, dynamic>;
                      return (dataB['votes'] ?? 0).compareTo(dataA['votes'] ?? 0);
                    });

                    int itemCount = (dadesPlayingNow != null ? 1 : 0) + llistaVotacions.length;

                    if (itemCount == 0) {
                      return const Center(
                        child: Text("La pista està buida. Sol·licita una cançó!",
                            style: TextStyle(color: Colors.white70, fontSize: 18)),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        if (dadesPlayingNow != null) {
                          if (index == 0) {
                            return Column(
                              children: [
                                _constructorPlayingNow(dadesPlayingNow!),
                                const SizedBox(height: 20),
                              ],
                            );
                          }
                          final doc = llistaVotacions[index - 1];
                          return _constructorCartaVotacio(doc.id, doc.data() as Map<String, dynamic>);
                        }

                        final doc = llistaVotacions[index];
                        return _constructorCartaVotacio(doc.id, doc.data() as Map<String, dynamic>);
                      },
                    );
                  },
                ),
              ),
              _constructorBotoBottom(),
              const Padding(
                padding: EdgeInsets.all(8.0),
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
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const introduirCodi())),
          ),
          Expanded(child: Image.asset('assets/Logo_FlowVenue.png', height: 40, fit: BoxFit.contain)),
          IconButton(
            icon: const Icon(Icons.rss_feed, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SocialFeedView(usuari: widget.usuari))),
          ),
        ],
      ),
    );
  }

  Widget _constructorPlayingNow(Map<String, dynamic> canco) {
    double progress = _duradaTotalMs > 0 ? (_posicioActualMs / _duradaTotalMs).clamp(0.0, 1.0) : 0.0;

    Duration actual = Duration(milliseconds: _posicioActualMs);
    Duration total = Duration(milliseconds: _duradaTotalMs);
    String format = "${actual.inMinutes.toString().padLeft(2, '0')}:${(actual.inSeconds % 60).toString().padLeft(2, '0')} / "
        "${total.inMinutes.toString().padLeft(2, '0')}:${(total.inSeconds % 60).toString().padLeft(2, '0')}";

    return Card(
      color: Colors.white54,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(canco['cover'] ?? '', width: 80, height: 80, fit: BoxFit.cover,
                      errorBuilder: (_,__,___) => Container(width: 80, height: 80, color: Colors.grey[800], child: const Icon(Icons.music_note, color: Colors.white))),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(canco['title'] ?? '', style: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(canco['artist'] ?? '', style: const TextStyle(color: Colors.black54, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            Slider(value: progress, onChanged: (v) {}, activeColor: Colors.pinkAccent, inactiveColor: Colors.black12),
            Align(alignment: Alignment.centerRight, child: Text(format, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold))),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(songData['cover'] ?? '', width: 50, height: 50, fit: BoxFit.cover,
              errorBuilder: (_,__,___) => const Icon(Icons.music_note, color: Colors.pinkAccent)),
        ),
        title: Text(songData['title'] ?? '', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(songData['artist'] ?? '', style: const TextStyle(color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_upward_rounded, color: Colors.pink, size: 22),
              onPressed: () => _dbServices.votarCanco(widget.idFesta, docId),
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
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE94E77), shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 15)),
        onPressed: () async {
          final nova = await Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchView()));
          if (nova != null) _dbServices.solLicitardCanco(widget.idFesta, nova);
        },
        child: const Center(child: Text("Solicita una Canción!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
      ),
    );
  }
}