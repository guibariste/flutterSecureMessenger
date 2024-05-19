import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Deconnexion extends StatelessWidget {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final Function() onLogout;

  const Deconnexion({Key? key, required this.onLogout}) : super(key: key);

  void deconnecterUtilisateur(context) async {
    onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        deconnecterUtilisateur(context);
      },
      child: const Text('Déconnexion'),
    );
  }
}
