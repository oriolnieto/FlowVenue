import 'package:flowvenue/model/party_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DbServices {
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
}