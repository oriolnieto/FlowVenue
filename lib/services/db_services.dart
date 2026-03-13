import 'package:flowvenue/model/party_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DbServices {
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
}