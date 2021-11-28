import 'package:firebase_app/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_app/screens/welcome_screen.dart';
import 'package:firebase_app/screens/login_screen.dart';
import 'package:firebase_app/screens/registration_screen.dart';
import 'package:firebase_app/screens/chat_screen.dart';

void main() async {
  runApp(FlashChat());
  await Firebase.initializeApp();
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        ChatScreen.id: (context) => ChatScreen()
      },
    );
  }
}
