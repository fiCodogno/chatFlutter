import 'package:chat/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.orange.shade900,
        iconTheme: IconThemeData(color: Colors.yellow.shade800),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange.shade900,
          actionsIconTheme: const IconThemeData(color: Colors.white)  
        )
      ),
      home: const ChatScreen(),
      debugShowCheckedModeBanner: false,
      title: "Chat Online"
    );
  }
}
