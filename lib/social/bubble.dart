import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:chewie/chewie.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
//rien a faire lorsque lon relance lapp sans redemarrer le device la video saffiche plus c natif

class ChatBubble extends StatefulWidget {
  final String username;
  final String message;
  final int id;
  final int idConv;
  final bool isCurrentUser;
  final Image? userImage;
  final Function() onMessageTap;
  final bool selected;
  final List<int>? fileImage;
  // final List<int>? fileVideo;

  final bool? image;
  final bool? video;
  final List<int>? screenshot;
  // final Function() onVideoTap;

  const ChatBubble({
    Key? key,
    required this.username,
    required this.message,
    required this.id,
    required this.idConv,
    required this.isCurrentUser,
    required this.userImage,
    required this.onMessageTap,
    required this.selected,
    required this.fileImage,
    required this.image,
    required this.video,
    required this.screenshot,
  }) : super(key: key);
  @override
  ChatBubbleState createState() => ChatBubbleState();
}

class ChatBubbleState extends State<ChatBubble> {
  // late VideoPlayerWidget videoPlayerWidget;
  VideoPlayerController _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4');
  Uint8List? fileByteScreenshot;
  Uint8List? fileByteImage;
  Uint8List? fileByteVideo;
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController = null;
  bool isPlaying = false;
  var username = "";
  var message = "";
  bool playVideo = false;
  bool isVideoLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      initializeVideoController();
      setState(() {});
    });

    initializeVideoController();

    username = widget.username;
    message = widget.message;
    fileByteScreenshot = widget.screenshot != null
        ? Uint8List.fromList(widget.screenshot!)
        : null;
    fileByteImage =
        widget.fileImage != null ? Uint8List.fromList(widget.fileImage!) : null;

    _chewieController = null;
  }

  Container buildVideoContainer() {
    if (playVideo && fileByteVideo != null && widget.screenshot != null) {
      if (_chewieController != null)
        return Container(
            width: 200,
            height: 200,
            child: Chewie(controller: _chewieController!));
    }
    return Container(); // Retourne un conteneur vide si les conditions ne sont pas remplies.
  }

  void clearCache() {
    DefaultCacheManager().emptyCache();
  }

  Widget buildMediaContainer() {
    if (!playVideo && widget.screenshot != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.memory(
            fileByteScreenshot!,
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
          GestureDetector(
            onTap: () {
              getVideo();
              setState(() {
                playVideo = true;
              });
            },
            // Action à effectuer lorsqu'on clique sur l'icône de lecture

            child: const Icon(
              Icons.play_circle_filled,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      );
    } else {
      return buildVideoContainer();
    }
  }

  void initializeVideoController() async {
    clearCache();
    if (widget.video == true && fileByteVideo != null && !isVideoLoaded) {
      final tempDir = await getTemporaryDirectory();

      // Ajoutez un identifiant unique basé sur la date et l'heure actuelles
      final uniqueId = DateTime.now().millisecondsSinceEpoch;

      final tempVideoFile = File('${tempDir.path}/temp_video_$uniqueId.mp4');
      await tempVideoFile.writeAsBytes(fileByteVideo!);
      _chewieController?.dispose();

      _videoPlayerController = VideoPlayerController.file(tempVideoFile);
      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoPlay: true,
        autoInitialize: true,
        looping: false,
      );

      if (mounted) {
        setState(() {
          isVideoLoaded = true;
        });
      }
    }
  }

  void getVideo() async {
    print("cbon");
    try {
      if (fileByteVideo != null) {
        setState(() {
          fileByteVideo = null;
          isVideoLoaded = false;
        });
      }

      final response = await http.post(
        // Uri.parse('http://localhost:8080/getVideo'),
        Uri.parse('http://10.0.2.2:8080/getVideo'),
        body: json.encode({
          'id': widget.id,
          'idConv': widget.idConv,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<int> file = List<int>.from(data['video']['data']);
        print(file);
        // print(data['video']['data']);
        // sendVideoToBubble(data['video']['data']);
        setState(() {
          fileByteVideo = file != null ? Uint8List.fromList(file) : null;
          // if (!initie) {
          // print(fileByteVideo);
          isVideoLoaded = false;
          initializeVideoController();
          // }
          // _initializeController();
        });
      } else {
        print('Échec de la requête HTTP avec le code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onMessageTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: widget.isCurrentUser
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: widget.userImage?.image,
                child: widget.userImage == null
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.selected
                      ? Colors.grey
                      : (widget.isCurrentUser ? Colors.blue : Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.fileImage != null)
                      Image.memory(
                        fileByteImage!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    //------------------VIDEO---------------

                    // if (widget.screenshot != null && !playVideo)
                    // Stack(
                    //   alignment: Alignment.center,
                    //   children: [
                    //     Image.memory(
                    //       fileByteScreenshot!,
                    //       width: 150,
                    //       height: 150,
                    //       fit: BoxFit.cover,
                    //     ),
                    //     GestureDetector(
                    //       onTap: () {
                    //         getVideo();
                    //         setState(() {
                    //           playVideo = true;
                    //         });
                    //       },
                    //       // Action à effectuer lorsqu'on clique sur l'icône de lecture

                    //       child: const Icon(
                    //         Icons.play_circle_filled,
                    //         color: Colors.white,
                    //         size: 40,
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    buildMediaContainer(),

                    Text(
                      '$username: $message',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // _chewieController!.dispose();
    // _videoPlayerController.dispose();
    super.dispose();
  }
}
