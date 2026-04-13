import 'package:cloud_firestore/cloud_firestore.dart';

class Festa {
  final String partyId;
  final int serveiId;
  final int djId;
  final int codiAcces;
  final String name;
  final DateTime fechaEvento;
  final bool actividad;
  final List<String> tipoFesta;

  final String localizacion;
  final double precio;
  final String imatge;

  Festa({
    required this.partyId,
    required this.serveiId,
    required this.djId,
    required this.codiAcces,
    required this.name,
    required this.fechaEvento,
    required this.actividad,
    required this.tipoFesta,

    this.localizacion = 'Sense lloc',
    this.precio = 0.0,
    this.imatge = '',
  });

  factory Festa.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Festa(
      partyId: doc.id,
      serveiId: data['servei_id'] ?? 0,
      djId: data['dj_id'] ?? 0,
      codiAcces: data['codi_acces'] ?? 0,
      name: data['name'] ?? '',
      fechaEvento: (data['fecha_evento'] as Timestamp).toDate(),
      actividad: data['actividad'] ?? false,
      tipoFesta: List<String>.from(data['tipo_festa'] ?? []),

      localizacion: data['localizacion'] ?? data['lloc'] ?? 'Sense lloc',
      precio: (data['precio'] ?? data['preu'] ?? 0).toDouble(),
      imatge: data['imatge'] ?? data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'servei_id': serveiId,
      'dj_id': djId,
      'codi_acces': codiAcces,
      'name': name,
      'fecha_evento': Timestamp.fromDate(fechaEvento),
      'actividad': actividad,
      'tipo_festa': tipoFesta,

      'localizacion': localizacion,
      'precio': precio,
      'imatge': imatge,
    };
  }

  bool validateAccessCode(int code) {
    return codiAcces == code;
  }

  Map<String, dynamic> getLiveFeed() {
    return {
      'party_id': partyId,
      'name': name,
      'actividad': actividad,
      'tipo_festa': tipoFesta,
      'fecha_evento': fechaEvento.toIso8601String(), // per a retornar la data si fos necessari en un format adequat en temps real
      'localizacion': localizacion,
      'precio': precio,
      'imatge': imatge,
      };
  }
}