import 'package:flowvenue/services/spotifyServices.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  List<Map<String, String>> _foundSongs = [];
  bool _isLoading = false;
  Timer? _debounce;
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() {
          _foundSongs = [];
          _isLoading = false;
        });
        return;
      }
      setState(() => _isLoading = true);
      final results = await spotifyServices().searchSongs(query);
      setState(() {
        _foundSongs = results;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Image.asset('assets/Logo_FlowVenue.png', height: 300, width: 300,),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white30),
                ),
                child: TextField(
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Busca tu canción..',
                    hintStyle: TextStyle(color: Colors.white60),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator(color: Colors.pinkAccent)
            else
              Expanded(
                child: _foundSongs.isNotEmpty ? ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _foundSongs.length,
                  itemBuilder: (context, index) {
                    final song = _foundSongs[index];
                    return Card( // retornem en forma de cards, esteticament basic de moment
                      color: Colors.white54,
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        leading: song['cover'] != null && song['cover']!.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            song['cover']!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.music_note, color: Colors.pinkAccent, size: 40),
                          ),
                        )
                            : const Icon(Icons.music_note, color: Colors.pinkAccent, size: 40),
                        title: Text(
                          song['title']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis, // per a que no peti la card el titol llarg
                        ),
                        subtitle: Text(song['artist']!),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                        },
                      ),
                    );
                  },
                )
                    : const Text('',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}