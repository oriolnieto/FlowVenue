import 'package:flowvenue/view/introduirCodi.dart';
import 'package:flutter/material.dart';
import 'package:flowvenue/view/partyFeed_view.dart';
import 'package:flowvenue/view/login_view.dart';
import 'package:flowvenue/view/socialFeedView_view.dart';
import 'package:flowvenue/view/buscador_view.dart';

void main() {
  runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: introduirCodi()
      ),
  );
}