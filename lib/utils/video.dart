// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:chewie/chewie.dart';

// class VideoPlayerWidget extends StatefulWidget {
//   final Uint8List videoFile;
//   final double width;
//   final double height;

//   const VideoPlayerWidget({
//     Key? key,
//     required this.videoFile,
//     required this.width,
//     required this.height,
//   }) : super(key: key);

//   @override
//   VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
// }

// class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
//   late VideoPlayerController _videoPlayerController;
//   late ChewieController _chewieController;

//   @override
//   void initState() {
//     super.initState();
//     initializeVideoController();
//   }

//   void initializeVideoController() async {
//     final tempDir = await getTemporaryDirectory();
//     final tempVideoFile = File('${tempDir.path}/temp_video.mp4');
//     await tempVideoFile.writeAsBytes(widget.videoFile);

//     _videoPlayerController = VideoPlayerController.file(tempVideoFile);
//     await _videoPlayerController.initialize();

//     _chewieController = ChewieController(
//       videoPlayerController: _videoPlayerController,
//       aspectRatio: _videoPlayerController.value.aspectRatio,
//       autoPlay: true,
//       looping: false,
//       // Vous pouvez également configurer d'autres paramètres Chewie ici
//     );

//     if (mounted) {
//       setState(() {});
//     }
//   }

//   bool isPlaying() {
//     return _chewieController.isPlaying;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _videoPlayerController.value.isInitialized
//         ? Chewie(controller: _chewieController)
//         : CircularProgressIndicator();
//   }

//   @override
//   void dispose() {
//     _chewieController.dispose();
//     _videoPlayerController.dispose();
//     super.dispose();
//   }
// }
