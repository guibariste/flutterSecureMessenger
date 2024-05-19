import 'package:flutter/material.dart';
import 'package:secure_messenger/utils/http.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Ajout du package
import 'package:local_auth/local_auth.dart';
import 'package:http/http.dart' as http;
import 'package:secure_messenger/utils/socket.dart';
import 'package:secure_messenger/homePage.dart';

class ConnexionPage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final String username;

  const ConnexionPage({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
    required this.username,
  }) : super(key: key);

  @override
  ConnexionPageState createState() => ConnexionPageState();
}

class ConnexionPageState extends State<ConnexionPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  bool obscurePassword = true;
  String? empreinte;
  String? identifiant;
  bool co = false;
  late WebSocketManager web;
  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  @override
  void dispose() {
    // Nettoyer les contrôleurs lors de la suppression du widget
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
    } catch (e) {
      canCheckBiometrics = false;
    }

    if (canCheckBiometrics) {
      // Vérifier si les données d'empreinte digitale existent dans Flutter Secure Storage
      empreinte = await storage.read(key: 'empreinte');
      identifiant = await storage.read(key: 'identifiant');

      if (empreinte != null && identifiant != null) {
        // Afficher une boîte de dialogue demandant à l'utilisateur s'il souhaite utiliser l'empreinte digitale
        _showFingerprintDialog();
      }
    }
  }

  Future<void> _showFingerprintDialog() async {
    bool accepteEmpreinte = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Connexion par Empreinte Digitale'),
          content: const Text(
              'Voulez-vous vous connecter à l\'aide de l\'empreinte digitale ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Utilisateur accepte
              },
              child: const Text('Oui'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Utilisateur refuse
              },
              child: const Text('Non'),
            ),
          ],
        );
      },
    );

    if (accepteEmpreinte) {
      bool authentifie = await _authenticateWithFingerprint();

      if (authentifie) {
        co = true;
        _login(context);
      } else {
        // Authentification échouée, gérer en conséquence
        // Vous pouvez afficher un message d'erreur ou prendre d'autres mesures
      }
    }
  }

  Future<bool> _authenticateWithFingerprint() async {
    try {
      return await _localAuthentication.authenticate(
        localizedReason:
            'Scan your fingerprint (or face or whatever) to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  void _login(context) async {
    var pseudos = usernameController.text;
    http.Response response;
    ApiService apiService = ApiService();
    try {
      if (co) {
        response = await apiService.logwithEmpreinte(empreinte!, identifiant!);
      } else {
        response = await apiService.login(pseudos, passwordController.text);
      }
      if (response.statusCode == 200) {
        envoiPseudo(pseudos);
        var data = json.decode(response.body);

        await storage.write(key: 'token', value: data['token']);
        await storage.write(key: 'userId', value: data['userId']);
        await storage.write(key: 'username', value: data['username']);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(User(
            username: data['username'],
            token: data['token'],
            userId: data['userId'],
            connecte: true));

        Provider.of<NavigationProvider>(context, listen: false).currentIndex =
            0;

        _showDialog(context, "Succès", "Connexion réussie: Bienvenue $pseudos");
      } else {
        _showDialog(context, "Erreur", "Échec de la connexion");
      }
    } catch (e) {
      _showDialog(context, "Erreur", "Une erreur est survenue: $e");
    }
  }

  void envoiPseudo(user) {
    final webSocketManager =
        context.read<WebSocketManagerProvider>().webSocketManager;
    webSocketManager.majWs(user);
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
  // Widget build(BuildContext context) {
  //   double paddingValue = widget.screenWidth * 0.1;
  //   return Scaffold(
  //     appBar: AppBar(title: Text('Connexion')),
  //     body: Center(
  //       child: Padding(
  //         padding: EdgeInsets.all(paddingValue),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: <Widget>[
  //             TextFormField(
  //               controller: usernameController,
  //               decoration: InputDecoration(labelText: 'Email'),
  //             ),
  //             SizedBox(height: paddingValue),
  //             TextFormField(
  //               controller: passwordController,
  //               obscureText:
  //                   obscurePassword, // Utilisation de la variable pour masquer/afficher le mot de passe
  //               decoration: InputDecoration(
  //                 labelText: 'Mot de passe',
  //                 suffixIcon: IconButton(
  //                   icon: Icon(
  //                     obscurePassword ? Icons.visibility : Icons.visibility_off,
  //                   ),
  //                   onPressed: () {
  //                     setState(() {
  //                       obscurePassword = !obscurePassword;
  //                     });
  //                   },
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 20),
  //             ElevatedButton(
  //               onPressed: () {
  //                 _login(context);
  //               },
  //               child: const Text('Connexion'),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget build(BuildContext context) {
    double paddingValue = widget.screenWidth * 0.1;
    return Scaffold(
      appBar: AppBar(title: Text('Connexion')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(paddingValue),
          child: SingleChildScrollView(
            // Ajoutez le SingleChildScrollView ici
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                SizedBox(height: paddingValue),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _login(context);
                  },
                  child: const Text('Connexion'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
