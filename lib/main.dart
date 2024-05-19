import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/utils/styles.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:secure_messenger/utils/socket.dart';
import 'package:secure_messenger/homePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();
  String username = await storage.read(key: 'username') ?? 'non connecte';
  String userId = await storage.read(key: 'userId') ?? '0';
  String jeton = await storage.read(key: 'token') ?? '';

  final webSocketManager = WebSocketManager();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(User(
              username: username,
              token: jeton,
              userId: userId,
              connecte: false)),
        ),
        ChangeNotifierProvider(
          create: (context) => NavigationProvider()..currentIndex = 0,
        ),
        ChangeNotifierProvider(
          create: (context) => WebSocketManagerProvider(webSocketManager),
        ),
        ChangeNotifierProvider<TypingModel>(
          create: (_) => TypingModel(),
        ),
      ],
      child: MyApp(userId: userId, username: username, jeton: jeton),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String username;
  final String jeton;
  final String userId;

  const MyApp(
      {Key? key,
      required this.username,
      required this.jeton,
      required this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return ChangeNotifierProvider(
      create: (context) => NavigationProvider()..currentIndex = 0,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: const ColorScheme.highContrastLight(),
          // primaryColor: Colors.blue,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: raisedButtonStyle,
          ),
          inputDecorationTheme: myInputDecorationTheme,
        ),
        home: MyHomePage(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          username: username,
          jeton: jeton,
          userId: userId,
        ),
      ),
    );
  }
}
