import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiService {
  // Définir l'URL de base du serveur ici
  // static const String _baseUrl = 'http://localhost:8080';
  static const String _baseUrl = 'http://10.0.2.2:8080';

  // static const String _baseUrl = 'http://192.168.66.141:8080';

  Future<http.Response> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    return response;
  }

  Future<http.Response> logwithEmpreinte(
      String empreinte, String identifiant) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/logEmpreinte'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'empreinte': empreinte,
        'identifiant': identifiant,
      }),
    );

    return response;
  }

  Future<http.Response> getConv(String user, String correspondant) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/getConv'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user': user,
        'correspondant': correspondant,
      }),
    );

    return response;
  }

  Future<http.Response> getVideo(String id, String idConv) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/getVideo'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'id': id,
        'idConv': idConv,
      }),
    );

    return response;
  }

  Future<http.Response> getList(String user) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/getListe'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user': user,
      }),
    );

    return response;
  }

  Future<http.Response> logout(String userId, String username) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/logout'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'userId': userId,
        'username': username,
      }),
    );

    return response;
  }

  Future<http.Response> profil(String userId, String username) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/profil'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'userId': userId,
        'username': username,
      }),
    );

    return response;
  }

  Future<http.Response> image(String userId, String username) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/image'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'userId': userId,
        'username': username,
      }),
    );

    return response;
  }

  Future<http.Response> profilExt(String username) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/profilExt'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
      }),
    );

    return response;
  }

  Future<http.Response> imageExt(String username) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/imageExt'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
      }),
    );

    return response;
  }

  // Future<http.Response> imageMessage(String username, dynamic idConv) async {
  //   final response = await http.post(
  //     Uri.parse('$_baseUrl/imageMessage'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(<String, String>{
  //       'expediteur': username,
  //       'idConv': idConv,
  //     }),
  //   );

  //   return response;
  // }
  // Future<http.Response> obtenirImageProfil(
  //     String userId, String username) async {
  //   final response =
  //       await http.get(Uri.parse('$_baseUrl/profil/$userId/$username'));
  //   return response;
  // }

  Future<http.Response> verifSession(
      String userId, String username, String jeton) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/session'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'jeton': jeton,
        'userId': userId,
      }),
    );

    return response;
  }

  Future<http.Response> verifSocket(
    String username,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/socket'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
      }),
    );

    return response;
  }

  Future<http.MultipartRequest?> createInscriptionRequest(
      String username,
      String password,
      String mail,
      String ville,
      File? image,
      String? token) async {
    var uri = Uri.parse('$_baseUrl/inscription');
    var request = http.MultipartRequest('POST', uri)
      ..fields['username'] = username
      ..fields['password'] = password
      ..fields['mail'] = mail
      ..fields['ville'] = ville;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }
    if (token != null) {
      request.fields['token'] = token;
    }
    return request;
  }
}
