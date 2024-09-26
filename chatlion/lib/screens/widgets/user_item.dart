import 'package:chatlion/models/user.dart';
import 'package:chatlion/riverpod/chat_provider.dart';
import 'package:chatlion/screens/chat/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserItem extends StatelessWidget {
  final ChatUser user;

    const UserItem({super.key, required this.user});

   @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                chatId: ChatNotifier.getChatId(currentUser.uid, user.uid),
                userId: user.uid
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10), 
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent.withOpacity(0.5), 
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(user.image),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Last Active: ${timeago.format(user.lastActive)}',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 15),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Colors.white), 
          ],
        ),
      ),
    );
  }
}
