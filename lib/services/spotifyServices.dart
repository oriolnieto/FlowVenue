import 'dart:async';
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
        clientId: "341e49540e144486bde1d28472397608",
        redirectUrl: "flowvenue://callback",
      );
      return _isConnected;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  Stream<PlayerState> get playerStateStream => SpotifySdk.subscribePlayerState();

  Future<void> play(String spotifyUri) async => await SpotifySdk.play(spotifyUri: spotifyUri);
  Future<void> pause() async => await SpotifySdk.pause();
  Future<void> resume() async => await SpotifySdk.resume();
  Future<void> seekTo(int ms) async => await SpotifySdk.seekTo(positionedMilliseconds: ms);
}