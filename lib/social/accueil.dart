import 'package:flutter/material.dart';
import 'dart:convert';
import 'confirmation_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:secure_messenger/social/profilExt.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/homePage.dart';
import 'package:secure_messenger/utils/media.dart';

//pr plus tard fonction pr voir les personnes bloques et pouvoir les debloquer
//et voir aussi les demandes en attentes quon a fait pa s seulement les demandes des autres
class Accueil extends StatefulWidget {
  final String username;
  final double screenWidth;
  final double screenHeight;

  const Accueil({
    Key? key,
    required this.username,
    required this.screenWidth,
    required this.screenHeight,
  }) : super(key: key);

  @override
  AccueilState createState() => AccueilState();
}

class AccueilState extends State<Accueil> {
  late String pseudo;
  late bool connecte;

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    pseudo = userProvider.user.username!;
    connecte = userProvider.user.connecte!;
    print(connecte);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          color: Colors.grey,
          child: Center(
            child: Text(
              connecte
                  ? "Bienvenue sur secure-messenger $pseudo"
                  : "Bienvenue sur secure-messenger,Vous n'êtes pas connecté. Veuillez vous connecter dans le menu ou vous inscrire.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 25.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
