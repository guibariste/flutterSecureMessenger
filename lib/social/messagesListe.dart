import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/utils/http.dart';
import 'dart:convert';
import 'package:secure_messenger/homePage.dart';

class MessagesListe extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final String username;

  const MessagesListe({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
    required this.username,
  }) : super(key: key);

  @override
  _MessagesListeState createState() => _MessagesListeState();
}

class _MessagesListeState extends State<MessagesListe> {
  List<Map<String, dynamic>> _amis = [];
  late String pseudo;
  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    // final userProvider = Provider.of<UserProvider>(context);
    pseudo = userProvider.user.username!;
    _getListe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          // Display list of conversations
          // You can replace this with the actual widget for displaying conversations
          Expanded(
            child: ListView.builder(
              itemCount: _amis.length,
              itemBuilder: (BuildContext context, int index) {
                if (_amis.isNotEmpty) {
                  print(_amis[index]);
                  final ami = _amis[index];
                  final correspondant = ami['correspondant'];

                  if (correspondant != null) {
                    return ListTile(
                      title: Text(correspondant),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            child: Text('Profil'),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Provider.of<NavigationProvider>(context,
                                      listen: false)
                                  .setFriendUsername(correspondant);

                              // Utilisez Provider pour mettre à jour currentIndex
                              Provider.of<NavigationProvider>(context,
                                      listen: false)
                                  .currentIndex = 7;
                            },
                            child: Text('Voir la discussion'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Gérer le cas où la clé 'correspondant' est manquante
                    return Container();
                  }
                } else {
                  // Gérer le cas où la liste est vide
                  return Container();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _getListe() async {
    ApiService apiService = ApiService();
    try {
      var response = await apiService.getList(pseudo);

      if (response.statusCode == 200) {
        print("c bon");
        final data = json.decode(response.body);
        setState(() {
          // Assurez-vous que 'conv' est toujours une liste
          _amis = List<Map<String, dynamic>>.from(data['conv'] ?? []);
        });
      } else {
        // Gérer les cas d'erreur
      }
    } catch (e) {
      // Gérer les erreurs lors de la requête
    }
  }
}
