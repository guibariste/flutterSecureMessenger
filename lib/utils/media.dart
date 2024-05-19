import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:secure_messenger/utils/http.dart';

class MediaSelector {
  final ImagePicker _picker = ImagePicker();

  static Future<Image?> loadImage(String username) async {
    ApiService apiService = ApiService();
    try {
      var response = await apiService.imageExt(username);

      if (response.statusCode == 200) {
        return Image.memory(response.bodyBytes);
      } else {
        // Gérer les autres statuts HTTP
        return null;
      }
    } catch (e) {
      // Gérer les erreurs de requête
      return null;
    }
  }

  Future<File?> selectMedia(BuildContext context,
      {bool allowImage = true, bool allowVideo = true}) async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Choisir un média'),
          children: <Widget>[
            if (allowImage)
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ImageSource.camera);
                },
                child: Text('Prendre une Photo'),
              ),
            if (allowVideo)
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ImageSource.camera);
                },
                child: Text('Enregistrer une Vidéo'),
              ),
            if (allowImage)
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
                child: Text('Sélectionner depuis la Galerie'),
              ),
            if (allowVideo)
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
                child: Text('Sélectionner depuis la Galerie (Vidéo)'),
              ),
          ],
        );
      },
    );

    if (source != null) {
      if (allowImage) {
        final pickedImage = await _picker.pickImage(source: source);
        if (pickedImage != null) {
          return File(pickedImage.path);
        }
      } else if (allowVideo) {
        final pickedVideo = await _picker.pickVideo(source: source);
        if (pickedVideo != null) {
          return File(pickedVideo.path);
        }
      }
    }

    return null;
  }
}
