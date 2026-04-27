import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flowvenue/model/party_model.dart';
import 'package:flowvenue/model/users_model.dart';

class DbServices {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- GESTIÓN DE FESTE ---
  Future<Festa?> getFestaByAccessCode(int codiAcces) async {
    try {
      print('Buscando fiesta con código: $codiAcces');
      final snapshot = await _db
          .collection('festes')
          .where('codiAcces', isEqualTo: codiAcces)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return Festa.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('Error getFestaByAccessCode: $e');
      return null;
    }
  }

  // --- AUTENTICACIÓN Y USUARIOS ---
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
          return usuariExistent;
        } else {
          print('Contraseña incorrecta');
          return null;
        }
      } else {
        return await registre(username, password);
      }
    } catch (e) {
      print('Error login: $e');
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
        artistaSpotify: '',
      );
      await nouDoc.set(nouUsuari.toFirestore());
      return nouUsuari;
    } catch (e) {
      print('Error registro: $e');
      return null;
    }
  }

  Future<bool> updatePerfil(Usuari usuario) async {
    try {
      await _db.collection('users').doc(usuario.userId).update(usuario.toFirestore());
      return true;
    } catch (e) {
      print('Error actualizando perfil: $e');
      return false;
    }
  }

  // --- GESTIÓN DE POSTS (COMUNIDAD) ---

  /// Crea un post subiendo la imagen a Storage primero si existe
  Future<bool> crearPost({
    required String username,
    String? content,
    File? imatge,
  }) async {
    try {
      String? finalImageUrl;

      // 1. Si el usuario seleccionó una imagen, la subimos
      if (imatge != null) {
        finalImageUrl = await pujarFoto(imatge);
        if (finalImageUrl == null) return false; // Abortamos si falla la subida
      }

      // 2. Guardamos el post en Firestore
      await _db.collection('posts').add({
        'username': username,
        'content': content ?? '',
        'imageUrl': finalImageUrl ?? '',
        'likes': 0,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error creant post: $e');
      return false;
    }
  }

  /// Sube un archivo a Firebase Storage y retorna su URL pública
  Future<String?> pujarFoto(File imageFile) async {
    try {
      String name = 'posts/${DateTime.now().millisecondsSinceEpoch}.jpg';
      var ref = _storage.ref().child(name);

      // Subir archivo
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      // Retornar URL
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error pujant foto a Storage: $e');
      return null;
    }
  }

  Stream<QuerySnapshot> escoltarPosts() {
    return _db
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // --- VOTACIONES Y CANCIONES ---
  Stream<QuerySnapshot> escoltarVotacionsEnViu(String idFesta) {
    return _db
        .collection('festes')
        .doc(idFesta)
        .collection('votacions')
        .snapshots();
  }

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
          'uri': canco['uri'],
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
      print('Error eliminando canción: $e');
    }
  }
}