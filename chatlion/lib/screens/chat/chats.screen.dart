import 'package:chatlion/screens/profile/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:chatlion/models/chat_message.dart';
import 'package:chatlion/models/user.dart';
import 'package:chatlion/riverpod/chat_provider.dart';
import 'package:chatlion/screens/chat/chat_screen.dart';
import 'package:chatlion/screens/search/search_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future.microtask(
        () => ref.read(chatProvider.notifier).loadUsersAndLastMessages());
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Messages',
          style: GoogleFonts.poppins(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.w500),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UsersSearchScreen()));
            },
            icon: const Icon(Icons.search, color: Colors.black),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'new_group') {      
              } else if (value == 'settings') {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()));
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'new_group',
                child: Text('Yeni Grup', style: GoogleFonts.poppins()),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: Text('Ayarlar', style: GoogleFonts.poppins()),
              ),
            ],
            offset: const Offset(0, 50),
          ),
        ],
      ),
      body: Consumer(builder: (context, ref, _) {
        final chatState = ref.watch(chatProvider);
        if (chatState.isLoadingUser) {
          return const Center(child: CircularProgressIndicator());
        } else if (chatState.users.isNotEmpty) {
          return buildUserList(
              context, chatState.users, chatState.lastMessages);
        } else {
          return const Center(child: Text('Kullanılabilir veri yok'));
        }
      }),
    );
  }

  Widget buildUserList(BuildContext context, List<ChatUser> users,
      Map<String, ChatMessage> lastMessages) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        if (user.uid == currentUserId) return Container(); 

        final lastMessage = lastMessages[user.uid];
        if (lastMessage == null) {
          return Container();
        }
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.image),
            radius: 25,
          ),
          title: Text(
            user.username,
            style: GoogleFonts.poppins(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            lastMessage.content,
            style: GoogleFonts.poppins(color: Colors.black54, fontSize: 15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            DateFormat('HH:mm').format(lastMessage.sentTime),
            style: GoogleFonts.poppins(color: Colors.black45, fontSize: 13),
          ),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ChatScreen(
                chatId: ChatNotifier.getChatId(
                    FirebaseAuth.instance.currentUser!.uid, user.uid),
                userId: user.uid,
              ),
            ));
          },
        );
      },
    );
  }
}
