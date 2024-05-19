import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/formulaires/connexion.dart';
import 'package:secure_messenger/formulaires/inscription.dart';
import 'package:secure_messenger/social/amis.dart';
import 'package:secure_messenger/social/accueil.dart';
import 'package:secure_messenger/social/messages.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Ajout du package
import 'package:secure_messenger/social/profil.dart';
import 'package:secure_messenger/social/messagesListe.dart';
import 'package:secure_messenger/utils/http.dart';
import 'package:secure_messenger/utils/socket.dart';
import 'dart:convert';

class TypingModel extends ChangeNotifier {
  bool _isTyping = false;

  bool get isTyping => _isTyping;

  void setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }
}

class User {
  String? username;
  String? token;
  String? userId;
  bool? connecte;

  User({this.username, this.token, this.userId, this.connecte});
}

class UserProvider with ChangeNotifier {
  User _user = User();
  UserProvider(this._user);
  User get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}

class WebSocketManagerProvider with ChangeNotifier {
  final WebSocketManager _webSocketManager;

  WebSocketManagerProvider(this._webSocketManager);

  WebSocketManager get webSocketManager => _webSocketManager;

  @override
  void dispose() {
    _webSocketManager.dispose();
    super.dispose();
  }
}

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;
  String _friendUsername = "";

  String get friendUsername => _friendUsername;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setFriendUsername(String friendUsername) {
    _friendUsername = friendUsername;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  final String username;
  final String userId;

  final String jeton;

  const MyHomePage(
      {Key? key,
      required this.screenWidth,
      required this.screenHeight,
      required this.username,
      required this.jeton,
      required this.userId})
      : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // print("init");
      verifSession(context);
    });
  }

  void connexionWs(String username) {
    final webSocketManager =
        context.read<WebSocketManagerProvider>().webSocketManager;
    webSocketManager.connect(username);
  }

  @override
  Widget build(BuildContext context) {
    var navigationProvider = Provider.of<NavigationProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    void changePage(int index) {
      final userProvider = context.read<UserProvider>();
      // navigationProvider.currentIndex = index;
      Provider.of<NavigationProvider>(context, listen: false).currentIndex =
          index;
      print(navigationProvider.currentIndex);
      Navigator.of(context).pop(); // Ferme le drawer
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '',
          style: TextStyle(
              color: Colors.white), // Définir la couleur du texte en blanc
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                userProvider.user.username ?? 'non connecte',

                style: const TextStyle(
                    color:
                        Colors.white), // Définir la couleur du texte en blanc
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _showLogoutDialog(context);
            },
            child: Row(
              children: [
                if (userProvider.user.connecte != null &&
                    userProvider.user.connecte == true)
                  const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                const SizedBox(width: 4),
                if (userProvider.user.connecte != null &&
                    userProvider.user.connecte ==
                        true) // Espace entre l'icône et le texte
                  const Text(
                    'Déconnexion',
                    style: TextStyle(
                        color: Colors
                            .white), // Définir la couleur du texte en blanc
                  ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const DrawerHeader(
              child: Text('menu'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: const Text('Accueil'),
              onTap: () => changePage(0),
            ),
            if (userProvider.user.connecte == false)
              ListTile(
                title: const Text('Connexion'),
                onTap: () => changePage(2),
              ),
            if (userProvider.user.connecte == false)
              ListTile(
                title: const Text('Inscription'),
                onTap: () => changePage(3),
              ),
            if (userProvider.user.connecte != null &&
                userProvider.user.connecte == true)
              ListTile(
                title: const Text('Profil'),
                onTap: () => changePage(4),
              ),
            if (userProvider.user.connecte != null &&
                userProvider.user.connecte == true)
              ListTile(
                title: const Text('Amis'),
                onTap: () => changePage(5),
              ),
            if (userProvider.user.connecte != null &&
                userProvider.user.connecte == true)
              ListTile(
                title: const Text('Discussions'),
                onTap: () {
                  changePage(6);
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // navigationProvider.currentIndex = index;

          navigationProvider.currentIndex = index;
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          if (userProvider.user != null && !userProvider.user.connecte!)
            BottomNavigationBarItem(
              icon: Icon(Icons.login),
              label: 'Connexion',
            ),
          if (userProvider.user != null && userProvider.user.connecte!)
            BottomNavigationBarItem(
              icon: Icon(Icons.login),
              label: 'Profil',
            ),
          // Ajoutez plus d'éléments ici
        ],
      ),
      body: _getPage(navigationProvider.currentIndex),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return Accueil(
          screenWidth: widget.screenWidth,
          screenHeight: widget.screenHeight,
          username: widget.username,
        );
      case 1:
      case 2:
        return ConnexionPage(
          screenWidth: widget.screenWidth,
          screenHeight: widget.screenHeight,
          username: widget.username,
        );
      case 3:
        return InscriptionPage(
            screenWidth: widget.screenWidth, screenHeight: widget.screenHeight);

      case 4:
        return ProfilPage(
            screenWidth: widget.screenWidth,
            screenHeight: widget.screenHeight,
            username: widget.username,
            userId: widget.userId);
      case 5:
        return Amis(
          username: widget.username,
          screenWidth: widget.screenWidth,
          screenHeight: widget.screenHeight,
        );
      case 6:
        return MessagesListe(
          screenWidth: widget.screenWidth,
          screenHeight: widget.screenHeight,
          username: widget.username,
        );
      case 7:
        return Messages(
          screenWidth: widget.screenWidth,
          screenHeight: widget.screenHeight,
          username: widget.username,
        );

      default:
        return const Text('Page d\'accueil');
    }
  }

  void _logout(BuildContext context) async {
    final userProvider = context.read<UserProvider>();
    var pseudo = userProvider.user.username;
    var userId = userProvider.user.userId;
    ApiService apiService = ApiService();
    try {
      var response = await apiService.logout(userId!, pseudo!);

      if (response.statusCode == 200) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(User(
            username: "non connecte", token: "", userId: "0", connecte: false));
      }
    } catch (e) {}
  }

  void verifSession(BuildContext context) async {
    final userProvider = context.read<UserProvider>();

    const storage = FlutterSecureStorage();

    ApiService apiService = ApiService();
    try {
      var response = await apiService.verifSession(userProvider.user.userId!,
          userProvider.user.username!, userProvider.user.token!);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print(data['username']);
        print("laaaaa");
        // print("connecte");
        userProvider.setUser(User(
          username: userProvider.user.username,
          token: userProvider.user.token,
          userId: userProvider.user.userId,
          connecte: true,
        ));
        connexionWs(data['username']);
      } else if (response.statusCode == 301) {
        // print("connecteailleur");
        userProvider.setUser(User(
            username: "non connecte", token: "", userId: "0", connecte: false));

        await storage.delete(key: 'token');
        await storage.delete(key: 'username');
        await storage.delete(key: 'userId');

        connexionWs("non connecte");
      }
    } catch (e) {
      // print(e);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Déconnexion"),
          content: const Text("Voulez-vous vous déconnecter ?"),
          actions: [
            ElevatedButton(
              onPressed: () {
                final webSocketManager =
                    context.read<WebSocketManagerProvider>().webSocketManager;
                webSocketManager.deconnexion(widget.username);
                _logout(context);
                Provider.of<NavigationProvider>(context, listen: false)
                    .currentIndex = 0;
                Navigator.of(context).pop(); // Ferme le dialogue
              },
              child: const Text("Ok"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
              },
              child: const Text("Annuler"),
            ),
          ],
        );
      },
    );
  }
}
