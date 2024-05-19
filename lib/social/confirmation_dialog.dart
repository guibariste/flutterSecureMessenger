import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/homePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConfirmationDialog extends StatelessWidget {
  final String username;
  final String pseudo;

  const ConfirmationDialog(
      {Key? key, required this.username, required this.pseudo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un ami'),
      content: Text('Voulez-vous ajouter $username comme ami ?'),
      actions: [
        TextButton(
          child: const Text('Annuler'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Ajouter'),
          onPressed: () async {
            // addFriend(username);
            demandeAmi(pseudo, username, context);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void demandeAmi(pseudo, pseudoAmi, context) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/demandeAmi'),
        // Uri.parse('http://192.168.164.141:8080/demandeAmi'),

        body: json.encode({"pseudo": pseudo, 'pseudoDemande': pseudoAmi}),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print(data['message']);

        _showDialog(context, "Succès", "Une demande a été envoyée ");
        Provider.of<NavigationProvider>(context, listen: false).currentIndex =
            0;
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
