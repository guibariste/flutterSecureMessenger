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
class Amis extends StatefulWidget {
  final String username;
  final double screenWidth;
  final double screenHeight;

  const Amis({
    Key? key,
    required this.username,
    required this.screenWidth,
    required this.screenHeight,
  }) : super(key: key);

  @override
  AmisState createState() => AmisState();
}

class AmisState extends State<Amis> {
  final TextEditingController _searchController = TextEditingController();
  List<String> allUsers = [];
  List<Map<String, dynamic>> _amis = [];
  List<String> demandesAmis = [];
  bool isSearching = false;
  String selectedUser = '';
  bool affAmis = true;
  bool affdemandes = false;
  bool acceptDemandeAmi = false;
  bool showProfile = false;
  bool boutonPrecedent = false;
  bool bloque = false;
  late String pseudo;
  static const String _baseUrl = 'http://10.0.2.2:8080';
  // static const String _baseUrl = 'http://localhost:8080';
  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    pseudo = userProvider.user.username!;
    getFriends(pseudo);
    getDemandeAmis(pseudo);
  }

  List<String> filteredUsers() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
      });
      return [];
    }
    return allUsers
        .where((user) => user.toLowerCase().contains(query))
        .toList();
  }

// ...

  // @override
  // Widget build(BuildContext context) {
  //   Widget? content;
  //   if (showProfile) {
  //     setState(() {
  //       boutonPrecedent = true;
  //     });

  //     content = ProfilPageExt(
  //       screenWidth: widget.screenWidth,
  //       screenHeight: widget.screenHeight,
  //       username: selectedUser, // Pass the selected user's username
  //     );
  //   }
  //   if (!isSearching) {
  //     // Mode "Afficher demandes"
  //     if (affAmis) {
  //       content = Column(
  //         children: [
  //           TextButton(
  //             onPressed: () {
  //               setState(() {
  //                 affAmis = false;
  //                 affdemandes = true;
  //                 showProfile = false;
  //               });
  //             },
  //             child: const Text('Afficher demandes'),
  //           ),
  //           Expanded(
  //             child: ListView.builder(
  //               itemCount: _amis.length,
  //               itemBuilder: (BuildContext context, int index) {
  //                 String ami = _amis[index]['pseudo'];

  //                 return FutureBuilder<Image?>(
  //                   future: _loadImage(ami),
  //                   builder: (context, snapshot) {
  //                     if (snapshot.connectionState == ConnectionState.done) {
  //                       return ListTile(
  //                         title: Text(ami),
  //                         leading: CircleAvatar(
  //                           radius: 20,
  //                           backgroundImage: snapshot.data?.image,
  //                           child: snapshot.data == null
  //                               ? const Icon(Icons.person,
  //                                   size: 40, color: Colors.grey)
  //                               : null,
  //                         ),
  //                         trailing: Row(
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: [
  //                             ElevatedButton(
  //                               onPressed: () {
  //                                 Provider.of<NavigationProvider>(context,
  //                                         listen: false)
  //                                     .setFriendUsername(ami);
  //                                 Provider.of<NavigationProvider>(context,
  //                                         listen: false)
  //                                     .currentIndex = 7;
  //                               },
  //                               child: const Text('Demarrer une conversation'),
  //                             ),
  //                             const SizedBox(width: 8),
  //                             ElevatedButton(
  //                               onPressed: () {
  //                                 setState(() {
  //                                   showProfile = true;
  //                                   affAmis = false;
  //                                   affdemandes = false;
  //                                   selectedUser = ami;
  //                                 });
  //                               },
  //                               child: const Text('Profil'),
  //                             ),
  //                             // const SizedBox(width: 8),
  //                             // ElevatedButton(
  //                             //   onPressed: () {
  //                             //     setState(() {
  //                             //       bloque = true;
  //                             //     });
  //                             //     bloquerAmis(ami);
  //                             //   },
  //                             //   child: const Text('Bloquer'),
  //                             // ),
  //                           ],
  //                         ),
  //                       );
  //                     } else {
  //                       return const CircularProgressIndicator();
  //                     }
  //                   },
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       );
  //     } else if (affdemandes) {
  //       content = Column(
  //         children: [
  //           TextButton(
  //             onPressed: () {
  //               setState(() {
  //                 affAmis = true;
  //                 affdemandes = false;
  //                 showProfile = false;
  //               });
  //             },
  //             child: const Text('Afficher amis'),
  //           ),
  //           Expanded(
  //             child: ListView.builder(
  //               itemCount: demandesAmis.length,
  //               itemBuilder: (BuildContext context, int index) {
  //                 final demande = demandesAmis[index];
  //                 return ListTile(
  //                   title: Text('$demande vous a demande en ami:'),
  //                   trailing: Row(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       ElevatedButton(
  //                         onPressed: () {
  //                           setState(() {
  //                             acceptDemandeAmi = true;
  //                           });
  //                           acceptDemandeAmis(demandesAmis[index]);
  //                         },
  //                         child: const Text('accepter'),
  //                       ),
  //                       const SizedBox(
  //                         width: 8,
  //                       ),
  //                       ElevatedButton(
  //                         onPressed: () {
  //                           setState(() {
  //                             acceptDemandeAmi = false;
  //                           });
  //                           acceptDemandeAmis(demandesAmis[index]);
  //                         },
  //                         child: const Text('refuser'),
  //                       ),
  //                     ],
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       );
  //     }
  //   } else {
  //     content = ListView(
  //       children: filteredUsers().map((user) {
  //         return GestureDetector(
  //           onTap: () {
  //             if (_searchController.text.isEmpty) isSearching = false;
  //             setState(() {
  //               _searchController.text = user;
  //               selectedUser = user;
  //             });
  //           },
  //           child: FutureBuilder<Image?>(
  //             future: _loadImage(user),
  //             builder: (context, snapshot) {
  //               if (snapshot.connectionState == ConnectionState.done) {
  //                 return ListTile(
  //                   title: Text(user),
  //                   subtitle: Row(
  //                     children: [
  //                       CircleAvatar(
  //                         radius: 20,
  //                         backgroundImage: snapshot.data?.image,
  //                         child: snapshot.data == null
  //                             ? const Icon(Icons.person,
  //                                 size: 40, color: Colors.grey)
  //                             : null,
  //                       ),
  //                     ],
  //                   ),
  //                 );
  //               } else {
  //                 return const CircularProgressIndicator(); // Ajoutez un indicateur de chargement si nécessaire
  //               }
  //             },
  //           ),
  //         );
  //       }).toList(),
  //     );
  //   }

  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Row(
  //         children: [
  //           if (boutonPrecedent)
  //             ElevatedButton(
  //               onPressed: () {
  //                 setState(() {
  //                   affAmis = true;
  //                   affdemandes = false;
  //                   showProfile = false;
  //                   boutonPrecedent = false;
  //                 });
  //               },
  //               child: const Text('precedent'),
  //             ),
  //           Expanded(
  //             child: TextField(
  //               controller: _searchController,
  //               style: TextStyle(
  //                 fontSize: 16,
  //               ),
  //               decoration: InputDecoration(
  //                 hintText: 'Rechercher des personnes',
  //                 filled: true,
  //                 fillColor: Colors.white,
  //               ),
  //               maxLines: 1,
  //               onChanged: (query) {
  //                 if (query.isEmpty) {
  //                   setState(() {
  //                     isSearching = false;
  //                   });
  //                 } else {
  //                   setState(() {
  //                     isSearching = true;
  //                   });
  //                 }
  //                 getAllUsers(pseudo);
  //               },
  //             ),
  //           ),
  //           Column(
  //             children: [
  //               Container(
  //                 width: 300, // Ajustez la largeur ici
  //                 child: TextField(
  //                   controller: _searchController,
  //                   style: const TextStyle(
  //                     fontSize: 15,
  //                   ),
  //                   decoration: const InputDecoration(
  //                     hintText: 'Rechercher des personnes',
  //                     filled: true,
  //                     fillColor: Colors.white,
  //                     contentPadding: EdgeInsets.symmetric(
  //                         horizontal: 10), // Ajustez la marge intérieure ici
  //                   ),
  //                   maxLines: 1,
  //                   onChanged: (query) {
  //                     if (query.isEmpty) {
  //                       setState(() {
  //                         isSearching = false;
  //                       });
  //                     } else {
  //                       setState(() {
  //                         isSearching = true;
  //                       });
  //                     }
  //                     getAllUsers(pseudo);
  //                   },
  //                 ),
  //               ),
  //               // Le reste de votre contenu ici
  //             ],
  //           ),
  //           const SizedBox(width: 20),
  //           ElevatedButton(
  //             onPressed: () {
  //               // Récupérez le texte de _searchController
  //               String searchText = _searchController.text;

  //               // Vérifiez si le texte correspond à l'un des utilisateurs
  //               if (doesUserExist(searchText)) {
  //                 _showConfirmationDialog(searchText);
  //               } else {
  //                 // L'utilisateur n'existe pas
  //                 print("Cet utilisateur n'existe pas");
  //               }
  //             },
  //             child: const Text('Valider'),
  //           ),
  //         ],
  //       ),
  //     ),
  //     body: content,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (boutonPrecedent)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    affAmis = true;
                    affdemandes = false;
                    showProfile = false;
                    boutonPrecedent = false;
                  });
                },
                child: const Text('precedent'),
              ),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Rechercher des personnes',
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 1,
                onChanged: (query) {
                  setState(() {
                    if (query.isEmpty) {
                      isSearching = false;
                    } else {
                      isSearching = true;
                    }
                  });
                  getAllUsers(pseudo);
                },
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                String searchText = _searchController.text;
                if (doesUserExist(searchText)) {
                  _showConfirmationDialog(searchText);
                } else {
                  print("Cet utilisateur n'existe pas");
                }
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (showProfile)
              ProfilPageExt(
                screenWidth: widget.screenWidth,
                screenHeight: widget.screenHeight,
                username: selectedUser,
              ),
            if (!isSearching)
              if (affAmis)
                Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          affAmis = false;
                          affdemandes = true;
                          showProfile = false;
                        });
                      },
                      child: const Text('Afficher demandes'),
                    ),
                  ],
                ),
            if (!isSearching)
              if (affdemandes)
                Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          affAmis = true;
                          affdemandes = false;
                          showProfile = false;
                        });
                      },
                      child: const Text('Afficher amis'),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: demandesAmis.length,
                      itemBuilder: (BuildContext context, int index) {
                        //
                      },
                    ),
                  ],
                ),
            if (isSearching)
              ListView(
                shrinkWrap: true,
                children: filteredUsers().map((user) {
                  return GestureDetector(
                    onTap: () {
                      if (_searchController.text.isEmpty) isSearching = false;
                      setState(() {
                        _searchController.text = user;
                        selectedUser = user;
                      });
                    },
                    child: FutureBuilder<Image?>(
                      future: _loadImage(user),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return ListTile(
                            title: Text(user),
                            subtitle: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: snapshot.data?.image,
                                  child: snapshot.data == null
                                      ? const Icon(Icons.person,
                                          size: 40, color: Colors.grey)
                                      : null,
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const CircularProgressIndicator(); // Ajoutez un indicateur de chargement si nécessaire
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(String username) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(pseudo: pseudo, username: username);
      },
    );
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

  bool doesUserExist(String username) {
    return allUsers.contains(username);
  }

  Future<Image?> _loadImage(String username) async {
    Image? loadedImage = await MediaSelector.loadImage(username);
    return loadedImage;
  }

  void getAllUsers(pseudo) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/getAllUsers'),
        // Uri.parse('http://192.168.164.141:8080/getAllUsers'),
        body: json.encode({
          'excludedPseudo': pseudo,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<String> users = [];
        final data = json.decode(response.body);
        for (var userData in data['users']) {
          users.add(userData);
        }

        setState(() {
          allUsers = users;
          isSearching = true; // Mettez à jour isSearching ici
        });
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }

  // void getAllUsers(pseudo) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$_baseUrl/getAllUsers'),
  //       // Uri.parse('http://192.168.164.141:8080/getAllUsers'),
  //       body: json.encode({
  //         'excludedPseudo': pseudo,
  //       }),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       List<String> users = [];
  //       final data = json.decode(response.body);
  //       for (var userData in data['users']) {
  //         users.add(userData);
  //       }

  //       setState(() {
  //         allUsers = users;
  //       });
  //     } else {
  //       print('Échec de la requête HTTP avec le code ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Erreur lors de la requête HTTP : $e');
  //   }
  // }

  void getFriends(pseudo) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/getAmis'),
        // Uri.parse('http://192.168.164.141:8080/getAmis'),
        body: json.encode({
          'pseudo': pseudo,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _amis = List<Map<String, dynamic>>.from(data['amis']);
        });
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }

  void getDemandeAmis(pseudo) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/getDemandeAmis'),
        // Uri.parse('http://192.168.164.141:8080/getDemandeAmis'),
        body: json.encode({
          'pseudo': pseudo,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          demandesAmis = List<String>.from(data['demandeAmis']);
          // print(demandesAmis);
        });
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }

  void acceptDemandeAmis(pseudoDemandeur) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/acceptDemandeAmis'),
        // Uri.parse('http://192.168.164.141:8080/acceptDemandeAmis'),
        body: json.encode({
          'pseudo': pseudo,
          'pseudoDemandeur': pseudoDemandeur,
          'accept': acceptDemandeAmi
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _showDialog(context, "Succès", "La réponse a été prise en compte");
        // renvoyer vers amis et mettre a jour la liste damis
        setState(() {
          affAmis = true;
          getFriends(pseudo);
        });
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }

  // void bloquerAmis(pseudoDemandeur) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$_baseUrl/bloquerAmis'),
  //       // Uri.parse('http://192.168.164.141:8080/bloquerAmis'),
  //       body: json.encode({
  //         'pseudo': pseudo,
  //         'pseudoDemandeur': pseudoDemandeur,
  //         'bloque': bloque
  //       }),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       final message = data['message'];
  //       _showDialog(context, "Succès", message);
  //       // renvoyer vers amis et mettre a jour la liste damis
  //       setState(() {
  //         affAmis = true;
  //         getFriends(pseudo);
  //       });
  //     } else {
  //       print('Échec de la requête HTTP avec le code ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Erreur lors de la requête HTTP : $e');
  //   }
  // }
}
