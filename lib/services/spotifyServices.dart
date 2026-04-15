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

  final String clientId = "c23d9c5e2c574f2caef31066aa6a361e";
  final String clientSecret = "e81e949f21ee4d61a6e0d4fdd1bcfd93";
  final String redirectUrl = "flowvenue://callback";

  Future<bool> connect() async {
    try {
      await getAuthToken();

      _isConnected = await SpotifySdk.connectToSpotifyRemote(
        clientId: clientId,
        redirectUrl: redirectUrl,
      );
      return _isConnected;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  Future<String?> getAuthToken() async {
    try {
      var token = await SpotifySdk.getAccessToken(
        clientId: clientId,
        redirectUrl: redirectUrl,
        scope: "app-remote-control,user-modify-playback-state,playlist-read-private,streaming,user-read-playback-state",
      );
      return token;
    } catch (e) {
      print("Error obtenint token: $e");
      return null;
    }
  }

  Stream<PlayerState> get playerStateStream => SpotifySdk.subscribePlayerState();

  Future<List<Map<String, String>>> searchSongs(String query) async {
    if (query.isEmpty) return [];

    try {
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
        final accessToken = jsonDecode(tokenResponse.body)['access_token'];

        final searchUrl = Uri.parse('https://api.spotify.com/v1/search?q=${Uri.encodeComponent(query)}&type=track&limit=10');
        final searchResponse = await http.get(searchUrl, headers: {'Authorization': 'Bearer $accessToken'});

        if (searchResponse.statusCode == 200) {
          final tracks = jsonDecode(searchResponse.body)['tracks']['items'] as List;

          return tracks.map((track) {
            return {
              'title': track['name'].toString(),
              'artist': track['artists'][0]['name'].toString(),
              'uri': track['uri'].toString(),
              'cover': (track['album']['images'] as List).isNotEmpty ? track['album']['images'][0]['url'].toString() : '',
            };
          }).toList();
        }
      }
    } catch (e) {
      print('Error buscant cançons: $e');
    }
    return [];
  }

  Future<List<Map<String, String>>> searchArtists(String query) async {
    if (query.isEmpty) return [];

    try {
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
        final accessToken = jsonDecode(tokenResponse.body)['access_token'];

        final searchUrl = Uri.parse('https://api.spotify.com/v1/search?q=${Uri.encodeComponent(query)}&type=artist&limit=10');
        final searchResponse = await http.get(searchUrl, headers: {'Authorization': 'Bearer $accessToken'});

        if (searchResponse.statusCode == 200) {
          final artists = jsonDecode(searchResponse.body)['artists']['items'] as List;

          return artists.map((artist) {
            return {
              'name': artist['name'].toString(),
              'uri': artist['uri'].toString(),
              'image': (artist['images'] as List).isNotEmpty ? artist['images'][0]['url'].toString() : '',
            };
          }).toList();
        }
      }
    } catch (e) {
      print('Error buscant artistes: $e');
    }
    return [];
  }

  Future<void> play(String spotifyUri) async {
    try {
      await SpotifySdk.play(spotifyUri: spotifyUri);
    } catch (e) {
      print("Error play: $e");
    }
  }

  Future<void> pause() async => await SpotifySdk.pause();

  Future<void> resume() async => await SpotifySdk.resume();

  Future<void> seekTo(int ms) async => await SpotifySdk.seekTo(positionedMilliseconds: ms);
}