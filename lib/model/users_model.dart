import 'package:cloud_firestore/cloud_firestore.dart';

class Usuari {
  final String userId;
  final int userIdInt;
  final String username;
  final String password;
  final String email;
  final String role;
  final List<String> favouriteGeneres;

  Usuari({
    required this.userId,
    required this.userIdInt,
    required this.username,
    required this.password,
    required this.email,
    required this.role,
    required this.favouriteGeneres,
  });

  factory Usuari.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Usuari(
      userId: doc.id,
      userIdInt: data['user_id'] ?? 0,
      username: data['username'] ?? '',
      password: data['password'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      favouriteGeneres: List<String>.from(data['favourite_generes'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userIdInt,
      'username': username,
      'password': password,
      'email': email,
      'role': role,
      'favourite_generes': favouriteGeneres,
    };
  }

  bool isAdmin() {
    return role.toLowerCase() == 'servei';
  }
}