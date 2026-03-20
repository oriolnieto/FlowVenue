import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowvenue/model/party_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowvenue/model/users_model.dart';

class DbServices {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<Festa?> getFestaByAccessCode(int codiAcces) async {  // passem el codi d'acces del pinput per validar-ho!
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('festes')
          .where('codi_acces', isEqualTo: codiAcces)
          .where('actividad', isEqualTo: true) // necessitem veure si esta activa, ja que si no ho estigues, no deixar entrar
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
}