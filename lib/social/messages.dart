import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:secure_messenger/utils/media.dart';
import 'package:secure_messenger/social/bubble.dart';
import 'package:secure_messenger/utils/socket.dart';
import 'package:secure_messenger/homePage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:secure_messenger/utils/http.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

//envoyer separement la capture de la video de la video ca gagnera du temps
//mais video thumnail bug
//envoyer des images,videos et audio
//faire attention lorsque je desactive getconv ya plus lidConv
class Messages extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  final String username;

  const Messages({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
    required this.username,
  }) : super(key: key);

  @override
  MessagesState createState() => MessagesState();
}

class MessagesState extends State<Messages> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();

  late String friendUsername;
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  dynamic idConv = "";
  late String pseudo;
  bool lu = false;
  Image? profilImage;
  late WebSocketManager webSocketManager;
  bool showButtons = false;
  dynamic idMess = "1";
  dynamic messageId = "";

  Image? imageMoi;
  // List<int>? screenshot;

  bool editingMessage = false;
  // String editedMessage = "";
  Image? imageCorrespondant;
  File? imageMessage;
  File? videoMessage;
  Image? imMess;
  // Uint8List? screenshote;
  bool isTyping = false;
  GlobalKey<ChatBubbleState>? chatBubbleKey = GlobalKey();

  final MediaSelector _imageSelector = MediaSelector();

  @override
  void initState() {
    super.initState();

    friendUsername =
        Provider.of<NavigationProvider>(context, listen: false).friendUsername;

    final userProvider = context.read<UserProvider>();

    pseudo = userProvider.user.username!;
    _getConv();
    webSocketManager =
        context.read<WebSocketManagerProvider>().webSocketManager;

    webSocketManager.onMessageUpdate((messages) {
      if (mounted)
        setState(() {
          _messages.addAll(messages);
          // print(messages);
        });
      webSocketManager.sendLu(pseudo, friendUsername, idConv);
    });

    _loadImage(pseudo).then((image) {
      setState(() {
        imageMoi = image;
      });
    });

    _loadImage(friendUsername).then((image) {
      setState(() {
        imageCorrespondant = image;
      });
    });

    webSocketManager.onMessageLu((data) {
      print(data);
      if (mounted) {
        if (idConv == data['idConv']) {
          setState(() {
            lu = data['lu'] ??
                false; // Assurez-vous que lu est initialisé correctement
          });
        }
      }
    });

    webSocketManager.onSuppr((data) {
      print(data);
      dynamic messageId = data; // Assurez-vous que 'id' est la clé correcte
      print("Message supprimé visuellement : $messageId");
      removeMessage(messageId);
    });
    TypingModel typingModel = Provider.of<TypingModel>(context, listen: false);

    webSocketManager.onMessageTyping((data) {
      print("recutap");
      if (idConv == data['idConv']) {
        typingModel.setTyping(data['typing']);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  void _onMessageControllerChange() {
    if (_messageController.text.isEmpty) {
      stopTyping();
    } else {
      startTyping();
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    return GestureDetector(
      onTap: () {
        setState(() {
          showButtons = false;
          editingMessage = false;
        });
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: showButtons ? 50 : 0,
            child: showButtons
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // showButtons = false;
                            editingMessage = true;
                            // editedMessage =
                            _messageController.text = _messages.firstWhere(
                                (message) =>
                                    message['id'] == idMess)['message'];
                            ;
                          });
                        },
                        child: const Text('Modifier'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          webSocketManager.sendSuppr(idMess);
                          setState(() {
                            showButtons = false;
                            editingMessage = false;
                          });
                        },
                        child: const Text('Supprimer'),
                      ),
                    ],
                  )
                : null,
          ),
          Text("Conversation avec $friendUsername"),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isCurrentUser = message['expediteur'] == pseudo;

                return ChatBubble(
                  username: message['expediteur'],
                  message: message['message'],
                  id: message['id'],
                  idConv: idConv,
                  isCurrentUser: isCurrentUser,
                  userImage: isCurrentUser ? imageMoi : imageCorrespondant,
                  onMessageTap: () {
                    setState(() {
                      idMess = message['id'];
                      showButtons = true;
                      editingMessage = false;
                      _messageController.text = '';
                    });
                  },
                  selected: showButtons ? message['id'] == idMess : false,
                  fileImage: message['fileImage'],
                  image: message['image'],
                  video: message['video'],
                  screenshot: message['screenshot'],
                  // onVideoTap: () {
                  //   // print(message['id']);
                  //   String idVideo = message['id'].toString();
                  //   getVideo(idVideo);
                  // },
                  // key: chatBubbleKey,
                );
              },
            ),
          ),

          //mis ca pr eviter dutiliser setstate qui reconstruit le widget tt le temps
          //et fait clignoter les images
          Consumer<TypingModel>(
            builder: (context, typingModel, child) {
              bool isTyping = typingModel.isTyping;

              return Visibility(
                visible: isTyping,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SpinKitThreeBounce(
                      color: Colors.blue,
                      size: 20.0,
                    ),
                  ),
                ),
              );
            },
          ),
          if (editingMessage)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      editingMessage = false;
                      showButtons = false;
                      _messageController.text = '';
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    setState(() {
                      final editedIndex = _messages
                          .indexWhere((message) => message['id'] == idMess);

                      if (editedIndex != -1) {
                        _messages[editedIndex]['message'] =
                            _messageController.text;
                      }
                      webSocketManager.sendEdit(
                          idMess, _messageController.text);
                      editingMessage = false;
                      showButtons = false;
                      _messageController.text = '';
                    });
                  },
                ),
              ],
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.video_library),
                onPressed: () async {
                  final video = await _imageSelector.selectMedia(context,
                      allowImage: false, allowVideo: true);

                  List<int> videoBytes = await video!.readAsBytes();

                  webSocketManager.sendMessage(
                    pseudo,
                    friendUsername,
                    "",
                    idConv,
                    fileVideo: videoBytes,
                    video: true,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: () async {
                  final image = await _imageSelector.selectMedia(context,
                      allowImage: true, allowVideo: false);

                  List<int> imageBytes = await image!.readAsBytes();

                  webSocketManager.sendMessage(
                    pseudo,
                    friendUsername,
                    "",
                    idConv,
                    fileImage: imageBytes,
                    image: true,
                  );
                },
              ),
              Expanded(
                child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Entrez votre message...',
                    ),
                    onChanged: (text) {
                      if (text.isEmpty) {
                        stopTyping();
                      } else {
                        startTyping();
                      }
                      // Appel de la fonction lorsque la saisie change
                    }),
              ),
              if (!editingMessage)
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    String message = _messageController.text;
                    if (message.isNotEmpty) {
                      stopTyping();
                      final web = context
                          .read<WebSocketManagerProvider>()
                          .webSocketManager;
                      web.sendMessage(
                        pseudo,
                        friendUsername,
                        message,
                        idConv,
                      );
                      setState(() {
                        lu = false;
                        _messageController.text = "";
                      });
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<Image?> _loadImage(String username) async {
    Image? loadedImage = await MediaSelector.loadImage(username);
    return loadedImage;
  }

  // void getVideo(String id) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('http://localhost:8080/getVideo'),
  //       // Uri.parse('http://192.168.164.141:8080/getVideo'),
  //       body: json.encode({
  //         'id': id,
  //         'idConv': idConv,
  //       }),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       // print(data['video']['data']);
  //       // sendVideoToBubble(data['video']['data']);
  //     } else {
  //       print('Échec de la requête HTTP avec le code ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Erreur lors de la requête HTTP : $e');
  //   }
  // }

  // void sendVideoToBubble(List<int> videoData) {
  //   // Vous pouvez utiliser une clé pour accéder à l'état de ChatBubble
  //   // Ici, je suppose que vous avez une clé appelée chatBubbleKey
  //   chatBubbleKey.currentState?.receiveVideo(videoData);
  // }

  void _getConv() async {
    ApiService apiService = ApiService();
    try {
      var response = await apiService.getConv(pseudo, friendUsername);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        Map<String, dynamic> convDetails =
            Map<String, dynamic>.from(data['convDetails'] ?? {});

        // Maintenant, vous pouvez utiliser la liste `convDetails` comme vous le souhaitez
        idConv = convDetails['idConv'];
        setState(() {
          lu = convDetails['lu'];
        });

        // correspondant = convDetails['correspondant'];

        List<Map<String, dynamic>> messages =
            List<Map<String, dynamic>>.from(convDetails['messages']);

        for (var messageData in messages) {
          if (messageData['file'] != null) {
            List<int> fileBytes = List<int>.from(messageData['file']['data']);

            // Ajouter le message avec le fichier à la liste `_messages`
            // setState(() {
            if (messageData['image']) {
              _messages.add({
                'id': messageData['id'],
                'expediteur': messageData['expediteur'],
                'idConv': messageData['idConv'],
                'message': messageData['message'],
                'fileImage': fileBytes,
                "image": messageData['image'],
              });
            }
            if (messageData['video']) {
              List<int> fileScreenshot =
                  List<int>.from(messageData['screenshot']['data']);

              _messages.add({
                'id': messageData['id'],
                'expediteur': messageData['expediteur'],
                'idConv': messageData['idConv'],
                'message': messageData['message'],
                "video": messageData['video'],
                "screenshot": fileScreenshot,
              });
            }
          } else {
            // Le message n'a pas de fichier, vous pouvez traiter les autres types de messages ici
            // setState(() {
            _messages.add({
              'id': messageData['id'],
              'expediteur': messageData['expediteur'],
              'idConv': messageData['idConv'],
              'message': messageData['message'],
            });
            // });
            // Vérifier si le message a un fichier
          }
        }
        webSocketManager.sendJoin(pseudo, idConv);
      } else {}
    } catch (e) {
      // Gérer les erreurs lors de la requête
    }
  }

  void startTyping() {
    // isTyping = true;
    webSocketManager.sendTyping(pseudo, friendUsername, true, idConv);
  }

  // Fonction pour arrêter l'indicateur de frappe
  void stopTyping() {
    // isTyping = false;
    webSocketManager.sendTyping(pseudo, friendUsername, false, idConv);
  }

  void removeMessage(dynamic messageId) {
    String stringId = messageId.toString();
    // print("Trying to remove message with ID: $stringId");
    if (mounted)
      setState(() {
        _messages.removeWhere((message) {
          String messageIdInList = message['id'].toString();
          bool shouldRemove = messageIdInList == stringId;

          if (shouldRemove) {
            // print("Message removed from the list: $stringId");
          }

          return shouldRemove;
        });
      });
  }
}
