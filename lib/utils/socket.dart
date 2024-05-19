import 'dart:typed_data';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io';

class WebSocketManager {
  late IO.Socket socket;

  void connect(String username) {
    // socket = IO.io('http://localhost:5555', <String, dynamic>{
    socket = IO.io('http://10.0.2.2:5555', <String, dynamic>{
      // socket = IO.io('http://192.168.66.141:5555', <String, dynamic>{
      'transports': ['websocket'],
    });
    authenticate(username);
  }

  void authenticate(String username) {
    if (username != "non connecte") {
      // Envoyer les détails d'authentification au serveur
      socket.emit('authenticate', {'username': username});
      print("connecté en tant que $username");
    }
  }

  void majWs(String username) {
    // Envoyer les détails d'authentification au serveur
    socket.emit('login', {'username': username});
  }

  void deconnexion(String username) {
    // Envoyer les détails d'authentification au serveur
    socket.emit('logout', {'username': username});
  }

  void sendMessage(
      String username, String correspondant, String message, dynamic idConv,
      {List<int>? fileImage, List<int>? fileVideo, bool? image, bool? video}) {
    // Envoi du message au serveur
    socket.emit('sendMessage', {
      'expediteur': username,
      'correspondant': correspondant,
      'message': message,
      'idConv': idConv,
      'fileImage': fileImage,
      'fileVideo': fileVideo,
      'image': image,
      'video': video,
      // "date": DateTime.now().toUtc(),
    });
  }

  void sendTyping(
      String username, String correspondant, bool typing, dynamic idConv) {
    // Envoi du message au serveur
    socket.emit('typing', {
      'expediteur': username,
      'correspondant': correspondant,
      'typing': typing,
      'idConv': idConv,
      // "date": DateTime.now().toUtc(),
    });
  }

  void sendQuit(String username, dynamic idConv) {
    // Envoi du message au serveur
    socket.emit('quit', {
      'expediteur': username,
      'idConv': idConv,
    });
  }

  void sendJoin(String username, dynamic idConv) {
    // Envoi du message au serveur
    socket.emit('join', {
      'expediteur': username,
      'idConv': idConv,
    });
  }

  void sendSuppr(dynamic id) {
    // Envoi du message au serveur
    socket.emit('suppr', {
      'id': id,
    });
  }

  void sendEdit(dynamic id, String message) {
    // Envoi du message au serveur
    socket.emit('edit', {
      'id': id,
      'text': message,
    });
  }

  void sendLu(String username, String correspondant, dynamic idConv) {
    // Envoi du message au serveur
    socket.emit('lu', {
      'expediteur': username,
      'correspondant': correspondant,
      'idConv': idConv,
    });
  }

  void onMessageUpdate(Function(List<Map<String, dynamic>>) callback) {
    socket.on('message', (data) {
      if (data['messages'] != null) {
        print("fiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii");
      }

      List<Map<String, dynamic>> messages =
          List<Map<String, dynamic>>.from(data['messages']);
      callback(messages);
    });
  }

  void onMessageLu(Function(dynamic) callback) {
    socket.on('recu', (data) {
      callback(data);
    });
  }

  void onSuppr(Function(dynamic) callback) {
    socket.on('supprime', (data) {
      callback(data);
    });
  }

  void onMessageTyping(Function(dynamic) callback) {
    socket.on('typingCo', (data) {
      callback(data);
    });
  }

  void dispose() {
    socket.dispose();
  }
}
