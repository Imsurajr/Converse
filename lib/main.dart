import 'package:converse/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ConVerse());
}

class ConVerse extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.black54),
          ),
        ),
        initialRoute: WelcomeScreen.wid,
        routes: {
          WelcomeScreen.wid: (context) => WelcomeScreen(),
          LoginScreen.lid: (context) => LoginScreen(),
          RegistrationScreen.rid: (context) => RegistrationScreen(),
          ChatScreen.cid: (context) => ChatScreen(),
        },
      ),
    );
  }
}
