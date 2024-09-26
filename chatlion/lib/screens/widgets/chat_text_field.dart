import 'dart:typed_data';
import 'package:chatlion/riverpod/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:chatlion/services/media_service.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatTextField extends StatefulWidget {
  final String receiverId;

  const ChatTextField({super.key, required this.receiverId});

  @override
  // ignore: library_private_types_in_public_api
  _ChatTextFieldState createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300], 
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined,
                        color: Colors.grey),
                    onPressed: () {
                      // Emoji seçme işlevi buraya eklenecek
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      cursorColor: Colors.blue, 
                      style: GoogleFonts.poppins(
                          color: Colors.black), 
                      decoration: InputDecoration(
                        hintText: 'Mesaj Yazın...',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey, 
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: _controller.text.isEmpty
                ? () => _sendImage(context, widget.receiverId)
                : () => _sendText(
                    context, _controller.text.trim(), widget.receiverId),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: _controller.text.isEmpty
                  ? const Color.fromARGB(255, 149, 104, 226)
                  : const Color(0xFF7C4DFF),
              child: Icon(
                _controller.text.isEmpty ? Icons.add : Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendText(BuildContext context, String text, String receiverId) async {
    if (text.isNotEmpty) {
      await ChatNotifier.addTextMessage(
        receiverId: widget.receiverId,
        content: text,
      );
      _controller.clear();
      setState(() {});
    }
  }

  void _sendImage(BuildContext context, String receiverId) async {
    Uint8List? image = await MediaService.pickImage();
    if (image != null) {
      await ChatNotifier.addImageMessage(
        receiverId: widget.receiverId,
        file: image,
      );
    }
  }
}
