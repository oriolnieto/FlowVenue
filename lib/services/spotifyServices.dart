import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class spotifyServices {
  static final spotifyServices _instance = spotifyServices._internal();
  factory spotifyServices() => _instance;
  spotifyServices._internal();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<bool> connect() async {
    try {
      _isConnected = await SpotifySdk.connectToSpotifyRemote(
        clientId: "c23d9c5e2c574f2caef31066aa6a361e",
        redirectUrl: "flowvenue://callback",
      );
      return _isConnected;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  Stream<PlayerState> get playerStateStream => SpotifySdk.subscribePlayerState();

  Future<List<Map<String, String>>> searchSongs(String query) async {
    if (query.isEmpty) return [];

    try {
      const String clientId = 'c23d9c5e2c574f2caef31066aa6a361e';
      const String clientSecret = 'e81e949f21ee4d61a6e0d4fdd1bcfd93';

      String credentials = base64.encode(utf8.encode('$clientId:$clientSecret'));

      final tokenResponse = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'grant_type': 'client_credentials'},
      );

      if (tokenResponse.statusCode == 200) {
        final tokenData = jsonDecode(tokenResponse.body);
        final accessToken = tokenData['access_token'];

        final searchUrl = Uri.parse('https://api.spotify.com/v1/search?q=$query&type=track&limit=5');
        final searchResponse = await http.get(searchUrl, headers: {'Authorization': 'Bearer $accessToken'},);

        if (searchResponse.statusCode == 200) {
          final searchData = jsonDecode(searchResponse.body);
          final tracks = searchData['tracks']['items'] as List;

          return tracks.map((track) {
            String coverUrl = '';
            if (track['album']['images'] != null && track['album']['images'].isNotEmpty) {
              coverUrl = track['album']['images'][0]['url'].toString();
            }
            return {
              'title': track['name'].toString(),
              'artist': track['artists'][0]['name'].toString(),
              'uri': track['uri'].toString(),
              'cover': coverUrl,
            };
          }).toList();
        }
      }
    } catch (e) {
      print('Error buscant: $e');
    }
    return [];
  }

  Future<void> play(String spotifyUri) async => await SpotifySdk.play(spotifyUri: spotifyUri);
  Future<void> pause() async => await SpotifySdk.pause();
  Future<void> resume() async => await SpotifySdk.resume();
  Future<void> seekTo(int ms) async => await SpotifySdk.seekTo(positionedMilliseconds: ms);
}