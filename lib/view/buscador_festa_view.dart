import 'package:flutter/material.dart';

class buscador_festa_view extends StatefulWidget {
  const buscador_festa_view({super.key});

  @override
  State<buscador_festa_view> createState() => _BuscadorFestaViewState();
}

class _BuscadorFestaViewState extends State<buscador_festa_view> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fem que el cos s'estengui sota l'AppBar si en tinguéssim
        body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/Background_App.png'),
                  fit: BoxFit.cover,

                ),
            ),

            