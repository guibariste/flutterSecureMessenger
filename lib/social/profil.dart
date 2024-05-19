import 'package:flutter/material.dart';
import 'package:secure_messenger/utils/http.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:secure_messenger/homePage.dart';
import 'package:secure_messenger/utils/media.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class ProfilPage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final String username;
  final String userId;

  const ProfilPage(
      {Key? key,
      required this.screenWidth,
      required this.screenHeight,
      required this.username,
      required this.userId})
      : super(key: key);

  @override
  ProfilPageState createState() => ProfilPageState();
}

class ProfilPageState extends State<ProfilPage> {
  Image? profilImage; // Variable pour stocker l'image de profil
  String mail = "";
  String ville = "";
  String usernames = "";
  late String pseudo;
  final MediaSelector _imageSelector = MediaSelector();

  File? _selectedImage;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Déplacez ici la logique qui dépend du contexte, comme verifSession().
    final userProvider = context.read<UserProvider>();

    pseudo = userProvider.user.username!;
    _profil();
    _image();
  }

  void _uploadImage() async {
    try {
      var userId = widget.userId;
      var username = pseudo;

      var selectedImage = _selectedImage!;

      var request = http.MultipartRequest(
          // 'POST', Uri.parse('http://localhost:8080/uploadImageProfil'));
          'POST',
          Uri.parse('http://10.0.2.2:8080/uploadImageProfil'));
      request.fields['userId'] = userId;
      request.fields['username'] = username;

      var imageFile =
          await http.MultipartFile.fromPath('image', selectedImage.path);
      request.files.add(imageFile);

      var response = await request.send();

      if (response.statusCode == 200) {
        //mettre les messages de succes et derreurs

        setState(() {
          profilImage = Image.file(selectedImage);
        });
        //met immediattement limage de profil a jour
      } else {
        // Gérer le cas où la création de la requête a échoué
      }
    } catch (e) {
      // Gérer les erreurs de requête
    }
  }

  void _chooseImage() async {
    final image = await _imageSelector.selectMedia(context,
        allowImage: true, allowVideo: false);
    ;
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
      _uploadImage();
    }
  }

  void _profil() async {
    final userProvider = Provider.of<UserProvider>(context);
    ApiService apiService = ApiService();
    try {
      // print(userProvider.user.username);
      var response = await apiService.profil(
        userProvider.user.userId!,
        userProvider.user.username!,
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        // Si la récupération réussit
        setState(() {
          mail = data['mail'];
          ville = data['ville'];
          usernames = userProvider.user.username!;
        });
      } else {
        // Gérer les autres statuts HTTP
      }
    } catch (e) {
      // Gérer les erreurs de requête
    }
  }

  void _image() async {
    final userProvider = Provider.of<UserProvider>(context);
    ApiService apiService = ApiService();
    try {
      // print(userProvider.user.username);
      var response = await apiService.image(
        userProvider.user.userId!,
        userProvider.user.username!,
      );

      if (response.statusCode == 200) {
        // Si la récupération réussit
        setState(() {
          profilImage = Image.memory(response.bodyBytes);
        });
      } else {
        // Gérer les autres statuts HTTP
      }
    } catch (e) {
      // Gérer les erreurs de requêteA
    }
  }

  @override
  Widget build(BuildContext context) {
    // double paddingValue = widget.screenWidth * 0.1;
    return Scaffold(
      appBar: AppBar(title: Text('Profil:$pseudo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profilImage?.image,
                    child: profilImage == null
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(
                      width: 20), // Ajustez cet espace selon vos besoins
                  ElevatedButton(
                    onPressed: _chooseImage,
                    child: const Text('Changer votre Image'),
                  ),
                ],
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
