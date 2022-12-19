import 'dart:io';

import 'package:chat/chat_message.dart';
import 'package:chat/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  User? _currentUser;
  bool _isLoadingImg = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  _getUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = authResult.user;

      return user;
    } catch (error) {
      return null;
    }
  }

  void _sendMessage({String? text, File? imgFile}) async {
    final User? user = await _getUser();

    if (user == null) {
      _scaffoldKey.currentState!.showSnackBar(const SnackBar(
        content: Text("Não foi possível realizar o login. Tente novamente!"),
        backgroundColor: Colors.redAccent,
      ));
    }

    Map<String, dynamic> data = {
      "uid": user!.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoURL,
      "time" : Timestamp.now()
    };

    if (imgFile != null) {
      FirebaseStorage feedStorage = FirebaseStorage.instance;
      Reference reference = feedStorage
          .ref()
          .child("${_currentUser?.uid}.${DateTime.now().millisecondsSinceEpoch.toString()}");

      setState(() {
        _isLoadingImg = true;
      });

      TaskSnapshot taskSnapshot = await reference.putFile(imgFile);
      String url = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl'] = url;

      setState(() {
        _isLoadingImg = false;
      });
    }

    if (text != null) {
      data['text'] = text;
    }

    FirebaseFirestore.instance.collection('messages').add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentUser != null
            ? "Olá, ${_currentUser!.displayName}"
            : "Chat Online"),
        centerTitle: true,
        elevation: 0,
        actions: [
          _currentUser != null
              ? IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                  },
                  icon: const Icon(Icons.logout))
              : Container()
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('messages').orderBy("time").snapshots(),
            builder: ((context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const Center(child: CircularProgressIndicator());

                default:
                  List<DocumentSnapshot> documents =
                      snapshot.data!.docs.reversed.toList();
                  return ListView.builder(
                    itemCount: documents.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> doc =
                          documents[index].data() as Map<String, dynamic>;
                      return ChatMessage(
                        doc, 
                        doc['uid'] == _currentUser?.uid
                      );
                    },
                  );
              }
            }),
          )),
          _isLoadingImg ? LinearProgressIndicator(color: Colors.yellow.shade800,) : Container(),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
