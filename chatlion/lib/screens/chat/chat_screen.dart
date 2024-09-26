import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chatlion/riverpod/chat_provider.dart';
import 'package:chatlion/screens/widgets/chat_messages.dart';
import 'package:chatlion/screens/widgets/chat_text_field.dart';

class ChatScreen extends ConsumerWidget {
  final String chatId;
  final String userId;

  const ChatScreen({super.key, required this.chatId, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).getUserById(userId);
    });

    return Scaffold(
      appBar: _buildAppBar(context, ref),
      body: Column(
        children: [
          Expanded(child: ChatMessages(receiverId: userId)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChatTextField(receiverId: userId),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }

  AppBar _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Consumer(builder: (context, watch, child) {
        final chatState = ref.watch(chatProvider);
        if (chatState.isLoadingUser) {
          return const CircularProgressIndicator();
        }
        return Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  NetworkImage(chatState.user?.image ?? 'default_image_url'),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Text(
              chatState.user?.username ?? 'User not found',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, size: 24, color: Colors.black),
          onPressed: () {
            // Placeholder for more actions
          },
        ),
      ],
    );
  }
}
