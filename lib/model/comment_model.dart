import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String username;
  final String content;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.username,
    required this.content,
    required this.timestamp,
  });

  factory Comment.fromFirestore(Map<String, dynamic> data, String id) {
    return Comment(
      id: id,
      username: data['username'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}