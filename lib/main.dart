import 'package:flowvenue/view/introduirCodi.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicialitzem les dades i un cop llest, executem l'app
  await initializeDateFormatting('es_ES', null);

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: introduirCodi(),
  ));
}