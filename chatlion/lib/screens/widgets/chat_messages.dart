import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatlion/models/chat_message.dart';
import 'package:chatlion/screens/widgets/empty_widget.dart';
import 'package:chatlion/screens/widgets/message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatlion/riverpod/chat_provider.dart'; 

class ChatMessages extends ConsumerWidget {
  final String receiverId;

  const ChatMessages({super.key, required this.receiverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).getMessagesForChat(receiverId);
    });

    return Consumer(builder: (context, ref, child) {
      final chatState = ref.watch(chatProvider);
      if (chatState.isLoadingUser) {
        return const Expanded(
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (chatState.messages.isEmpty) {
        return const Expanded(
          child: EmptyWidget(text: 'No messages yet'),
        );
      }

      return Expanded(
        child: ListView.builder(
          itemCount: chatState.messages.length,
          reverse: true,
          itemBuilder: (context, index) {
            final message = chatState.messages[index];
            bool isMe = message.senderId == FirebaseAuth.instance.currentUser?.uid;
            return MessageBubble(
              isMe: isMe,
              message: message,
              isImage: message.messageType == MessageType.image,
            );
          },
        ),
      );
    });
  }
}
