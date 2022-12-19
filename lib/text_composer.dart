import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  const TextComposer(this.sendMessage, {super.key});

  final Function({String text, File imgFile}) sendMessage;

  @override
  State<TextComposer> createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  bool _isComposing = false;

  final TextEditingController _messageController = TextEditingController();

  void _reset() {
    _messageController.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.photo_camera),
            onPressed: () async {
              final XFile? imgXFile = await ImagePicker().pickImage(source: ImageSource.camera);
              if(imgXFile == null){
                return;
              }
              final File imgFile = File(imgXFile.path);
              widget.sendMessage(imgFile: imgFile);
            },
          ),
          Expanded(
              child: TextField(
            controller: _messageController,
            decoration: const InputDecoration.collapsed(
              hintText: "Enviar uma Mensagem",
            ),
            onChanged: (text) {
              setState(() {
                _isComposing = text.isNotEmpty;
              });
            },
            onSubmitted: (text) {
              widget.sendMessage(text: text);
              _reset();
            },
          )),
          IconButton(
              onPressed: _isComposing
                  ? () {
                      widget.sendMessage(text: _messageController.text);
                      _reset();
                    }
                  : null,
              icon: const Icon(Icons.send))
        ],
      ),
    );
  }
}
