import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flowvenue/model/party_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowvenue/model/users_model.dart';

class DbServices {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Festa?> getFestaByAccessCode(int codiAcces) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('festes')
          .where('codi_acces', isEqualTo: codiAcces)
          .where('actividad', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return Festa.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('Error getFestaByAccessCode: $e');
      return null;
    }
  }

  Future<Usuari?> login(String username, String password) async {
    try {
      final snapshot = await _db
          .collection('users')
          .where('username', isEqualTo: username.trim())
          .get();

      if (snapshot.docs.isNotEmpty) {
        final userData = snapshot.docs.first;
        final Usuari usuariExistent = Usuari.fromFirestore(userData);

        if (usuariExistent.password == password) {
          print('Login correcte per a: $username');
          return usuariExistent;
        } else {
          print('Contrasenya incorrecta');
          return null;
        }
      } else {
        print('Usuari nou detectat, registrant: $username');
        return await registre(username, password);
      }
    } catch (e) {
      print('Error a Firestore: $e');
      return null;
    }
  }

  Future<Usuari?> registre(String username, String password) async {
    try {
      final nouDoc = _db.collection('users').doc();

      Usuari nouUsuari = Usuari(
        userId: nouDoc.id,
        userIdInt: DateTime.now().millisecondsSinceEpoch,
        username: username.trim(),
        password: password,
        email: '',
        role: 'usuario',
        phone: 0,
        favouriteGeneres: [],
      );

      await nouDoc.set(nouUsuari.toFirestore());

      return nouUsuari;
    } catch (e) {
      print('Error creant el doc a Firestore: $e');
      return null;
    }
  }

  Future<bool> updatePerfil (Usuari usuario) async {
    try {
      await _db.collection('users').doc(usuario.userId).update(usuario.toFirestore());
      return true;

    } catch (e) {
      print('Error actualitzant perfil: $e');
      return false;
    }
  }

  Stream<QuerySnapshot> escoltarVotacionsEnViu(String idFesta) {
    return _db
        .collection('festes')
        .doc(idFesta)
        .collection('votacions')
        .snapshots();
  }

  // --- CANVI AQUÍ: GUARDEM LA URI ---
  Future<void> solLicitardCanco(String idFesta, Map<String, dynamic> canco) async {
    try {
      String docId = canco['title'].toString().replaceAll('/', '-');

      final docRef = _db.collection('festes').doc(idFesta).collection('votacions').doc(docId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.update({'votes': FieldValue.increment(1)});
      } else {
        await docRef.set({
          'title': canco['title'],
          'artist': canco['artist'],
          'cover': canco['cover'] ?? '',
          'uri': canco['uri'], // <--- AIXÒ ÉS EL QUE FALTAVA
          'votes': 1,
        });
      }
    } catch (e) {
      print('Error sol·licitant cançó: $e');
    }
  }

  Future<void> votarCanco(String idFesta, String docId) async {
    try {
      await _db.collection('festes').doc(idFesta).collection('votacions').doc(docId).update({
        'votes': FieldValue.increment(1)
      });
    } catch (e) {
      print('Error votant cançó: $e');
    }
  }

  Future<void> eliminarCanco(String idFesta, String docId) async {
    try {
      await _db.collection('festes').doc(idFesta).collection('votacions').doc(docId).delete();
    } catch (e) {
      print('Error eliminant cançó: $e');
    }
  }

  Future<bool> crearPost({
    required String username,
    String? content,
    String? imageUrl,
  }) async {
    try {
      await _db.collection('posts').add({
        'username': username,
        'content': content ?? '',
        'imageUrl': imageUrl ?? '',
        'likes': 0,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error creant post: $e');
      return false;
    }
  }

  Future<String?> pujarFoto(File imageFile) async {
    try {
      String name = 'posts/${DateTime.now().millisecondsSinceEpoch}.jpg';
      var ref = FirebaseStorage.instance.ref().child(name);
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Stream<QuerySnapshot> escoltarPosts() {
    return _db
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}

