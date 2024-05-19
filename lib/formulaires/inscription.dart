import 'package:flutter/material.dart';
import 'package:secure_messenger/utils/http.dart';
import 'dart:convert';
import 'package:secure_messenger/utils/media.dart';
import 'dart:io';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

// class InscriptionPage extends StatefulWidget {
//   final double screenWidth;
//   final double screenHeight;

//   InscriptionPage({required this.screenWidth, required this.screenHeight});

//   @override
//   _InscriptionPageState createState() => _InscriptionPageState();
// }
class InscriptionPage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  const InscriptionPage({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
  }) : super(key: key);

  @override
  InscriptionPageState createState() => InscriptionPageState();
}

class InscriptionPageState extends State<InscriptionPage> {
  // Déplacez vos contrôleurs, _selectedImage, et méthodes ici
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController villeController = TextEditingController();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final MediaSelector _imageSelector = MediaSelector();
  bool obscurePassword = true;
  File? _selectedImage;
  final Uuid uuid = Uuid();
  bool saveEmpreinte = false;

  final LocalAuthentication auth = LocalAuthentication();

  // bool? _canCheckBiometrics;
  // List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  bool supporteEmpreinte = false;
  bool supporteEmpreinte2 = false;

  @override
  void initState() {
    super.initState();
    auth.isDeviceSupported().then((bool isSupported) => setState(
          () => supporteEmpreinte = isSupported ? true : false,
        ));
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      supporteEmpreinte2 = canCheckBiometrics;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason:
            'Scan your fingerprint (or face or whatever) to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });

      if (authenticated) {
        saveEmpreinte = true;

        _showDialog(
          context,
          "Succès",
          "Votre empreinte digitale a été enregistrée avec succès",
        );
      }
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }
  }

  String generateUniqueToken() {
    return uuid.v4(); // Génère un UUID v4 (aléatoire)
  }

//annuler enregistrement d'empreinte
  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }

  void _inscr(BuildContext context) async {
    ApiService apiService = ApiService();
    try {
      var username = usernameController.text;
      var password = passwordController.text;
      var mail = mailController.text;
      var ville = villeController.text;
      var selectedImage = _selectedImage;
      String? uniqueToken;
      if (saveEmpreinte) {
        await secureStorage.write(
            key: 'identifiant', value: usernameController.text);

        // Générez un token unique
        uniqueToken = generateUniqueToken();

        // Enregistrez le token avec la clé 'empreinte'
        await secureStorage.write(key: 'empreinte', value: uniqueToken);
      }
      // Créez la requête en dehors de la vérification de nul
      var request = await apiService.createInscriptionRequest(
          username, password, mail, ville, selectedImage, uniqueToken);

      if (request != null) {
        var response = await request.send();

        if (response.statusCode == 201) {
          // Si la connexion réussit
          var data = json.decode(await response.stream.bytesToString());
          _showDialog(
              context, "Succès", "Inscription réussie: ${data['message']}");
        } else if (response.statusCode == 409) {
          // Si la connexion réussit
          var data = json.decode(await response.stream.bytesToString());
          _showDialog(
              context, "Succès", "utilisateur existe deja ${data['message']}");
        } else {
          // Si la connexion échoue
          _showDialog(context, "Erreur", "Échec de la connexion");
        }
      } else {
        // Gérer le cas où la création de la requête a échoué
        _showDialog(context, "Erreur", "requete nulle");
      }
    } catch (e) {
      // Gérer les erreurs de requête
      _showDialog(context, "Erreur", "Une erreur est survenue: $e");
    }
  }

  void _chooseImage() async {
    // final image = await _imageSelector.selectImage(context);
    final image = await _imageSelector.selectMedia(context,
        allowImage: true, allowVideo: false);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
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
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double paddingValue = widget.screenWidth * 0.02;
    return Scaffold(
      appBar: AppBar(title: Text('Inscription')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(paddingValue),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'username'),
              ),
              SizedBox(height: paddingValue),
              TextFormField(
                controller: passwordController,
                obscureText:
                    obscurePassword, // Utilisation de la variable pour masquer/afficher le mot de passe
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: paddingValue),
              TextFormField(
                controller: mailController,
                decoration: InputDecoration(labelText: 'Mail'),
              ),
              SizedBox(height: paddingValue),
              TextFormField(
                controller: villeController,
                decoration: InputDecoration(labelText: 'Ville'),
              ),
              SizedBox(height: paddingValue),
              ElevatedButton(
                onPressed: _chooseImage,
                child: Text('Choisir une Image'),
              ),
              // Afficher l'image sélectionnée si elle existe
              // if (_selectedImage != null) Image.file(_selectedImage!),
              ElevatedButton(
                onPressed: () async {
                  if (supporteEmpreinte && supporteEmpreinte2) {
                    print("c bon");
                    _authenticateWithBiometrics();
                  } else {
                    print("c pa bon");
                    _showDialog(
                      context,
                      "Erreur",
                      "Votre appareil ne prend pas en charge l'authentification biometrique",
                    );
                  }
                },
                child: Text('ajouter une empreinte'),
              ),
              ElevatedButton(
                onPressed: () {
                  _inscr(context);

                  // Logique de connexion
                },
                child: Text('Valider'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
