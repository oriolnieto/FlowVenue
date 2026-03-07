import 'package:flutter/material.dart';

class feedItem_model {
  final String id;
  final String title;
  final String artist;
  final String spotifyUri;
  final String imageUrl;
  final int votes;
  final Color cardColor;
  final bool isGradient;

  feedItem_model({
    required this.id,
    required this.title,
    required this.artist,
    required this.spotifyUri,
    required this.imageUrl,
    this.votes = 0,
    this.cardColor = const Color(0xFF1A1A1A),
    this.isGradient = false,
  });

  factory feedItem_model.fromJson(Map<String, dynamic> json) {
    return feedItem_model(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      spotifyUri: json['spotifyUri'],
      imageUrl: json['imageUrl'],
      votes: json['votes'] ?? 0,
    );
  }
}