import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; 
import 'package:chatlion/models/chat_message.dart'; 

class MessageBubble extends StatelessWidget {
  final bool isMe;
  final bool isImage;
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.isMe,
    required this.isImage,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 2,
        bottom: 2,
        left: isMe ? 50 : 12,
        right: isMe ? 12 : 50,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            gradient: isMe
                ? const LinearGradient(
                    colors: [Color(0xFFB388FF), Color(0xFF7C4DFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: !isMe ? const Color(0xFFE5E5E5) : null,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(24),
              topRight: const Radius.circular(24),
              bottomLeft:
                  isMe ? const Radius.circular(24) : const Radius.circular(0),
              bottomRight:
                  isMe ? const Radius.circular(0) : const Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isImage)
                  Text(
                    message.content,
                    style: GoogleFonts.poppins(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                    textAlign: isMe ? TextAlign.end : TextAlign.start,
                  ),
                if (isImage)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        message.content,
                        width: MediaQuery.of(context).size.width * 0.5,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    DateFormat('HH:mm').format(message.sentTime),
                    style: GoogleFonts.poppins(
                      color: isMe
                          ? Colors.white.withOpacity(0.80)
                          : Colors.black.withOpacity(0.80),
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
