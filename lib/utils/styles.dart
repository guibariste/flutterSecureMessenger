import 'package:flutter/material.dart';

final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
  foregroundColor: Colors.black87,
  backgroundColor: Color.fromARGB(255, 139, 168, 197),
  minimumSize: const Size(88, 36),
  padding: const EdgeInsets.symmetric(horizontal: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(50), // Bords bien ronds
    side: const BorderSide(
        color: Color.fromARGB(255, 13, 13, 13)), // Bordure autour du bouton
  ),
  textStyle: const TextStyle(
    color: Colors.black, // Couleur du texte du bouton
    fontWeight: FontWeight.bold, // Style de la police du texte
    fontSize: 16, // Taille du texte
  ),
);

final InputDecorationTheme myInputDecorationTheme = InputDecorationTheme(
  border: OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.grey),
    borderRadius: BorderRadius.circular(10),
  ),
  // contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  contentPadding: const EdgeInsets.only(left: 30, right: 30),
  labelStyle: const TextStyle(color: Colors.black),
  hintStyle: const TextStyle(color: Colors.grey),
  focusedBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.blue),
    borderRadius: BorderRadius.circular(10),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.grey),
    borderRadius: BorderRadius.circular(10),
  ),
);
