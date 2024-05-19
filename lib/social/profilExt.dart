import 'package:flutter/material.dart';
import 'package:secure_messenger/utils/http.dart';
import 'package:secure_messenger/utils/media.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:secure_messenger/homePage.dart';
import 'package:provider/provider.dart';

//faire la logique de bloquer debloquer la dedans
//et renvoyer les messagesadequats
class ProfilPageExt extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final String username; // Nouveau paramètre

  const ProfilPageExt({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
    required this.username,
    // Ajoutez vos nouveaux paramètres ici
  }) : super(key: key);

  @override
  ProfilPageExtState createState() => ProfilPageExtState();
}

class ProfilPageExtState extends State<ProfilPageExt> {
  // Définissez l'état de la classe ici, si nécessaire
  Image? profilImage; // Variable pour stocker l'image de profil
  String mail = "";
  String ville = "";
  String usernames = "";
  late String user;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Déplacez ici la logique qui dépend du contexte, comme verifSession().
    _profil();
    _loadImage(widget.username);
    final userProvider = context.read<UserProvider>();

    user = userProvider.user.username!;
  }

  void _profil() async {
    ApiService apiService = ApiService();
    try {
      // print(userProvider.user.username);
      var response = await apiService.profilExt(widget.username);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        // Si la récupération réussit
        setState(() {
          mail = data['mail'];
          ville = data['ville'];
          usernames = widget.username;
        });
      } else {
        // Gérer les autres statuts HTTP
      }
    } catch (e) {
      // Gérer les erreurs de requête
    }
  }

  void bloquerAmis(pseudoBloque) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/bloquerAmis'),
        // Uri.parse('http://192.168.164.141:8080/bloquerAmis'),
        body: json.encode({
          'pseudo': user,
          'pseudoDemandeur': pseudoBloque,
          'bloque': true,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        // _showDialog(context, "Succès", message);
        // renvoyer vers amis et mettre a jour la liste damis
        // setState(() {
        //   affAmis = true;
        //   getFriends(pseudo);
        // });
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }

  void _loadImage(String username) async {
    Image? loadedImage = await MediaSelector.loadImage(username);

    setState(() {
      profilImage = loadedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    // double paddingValue = widget.screenWidth * 0.1;
    return Scaffold(
      appBar: AppBar(title: Text('Profil')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: profilImage?.image,
                child: profilImage == null
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                usernames,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  bloquerAmis(widget.username);
                },
                child: const Text('Bloquer'),
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'Mail: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: mail),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'Ville: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ville),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              QrImageView(
                data: 'Username: $usernames\nMail: $mail\nVille: $ville',
                version: QrVersions.auto,
                size: 200.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
