// state/chat_state.dart
import 'package:chatlion/models/chat_message.dart';
import 'package:chatlion/models/user.dart';

class ChatState {
  final List<ChatUser> users;
  final ChatUser? user;
  final List<ChatMessage> messages;
  final List<ChatUser> search;
  final Map<String, List<ChatMessage>> chatMessages;
  final Map<String, ChatMessage> lastMessages;
  final bool isLoadingUser;

  ChatState({
    required this.users,
    required this.user,
    required this.messages,
    required this.search,
    required this.chatMessages,
    required this.lastMessages,
    required this.isLoadingUser,
  });

  ChatState copyWith({
    List<ChatUser>? users,
    ChatUser? user,
    List<ChatMessage>? messages,
    List<ChatUser>? search,
    Map<String, List<ChatMessage>>? chatMessages,
    Map<String, ChatMessage>? lastMessages,
    bool? isLoadingUser,
  }) {
    return ChatState(
      users: users ?? this.users,
      user: user ?? this.user,
      messages: messages ?? this.messages,
      search: search ?? this.search,
      chatMessages: chatMessages ?? this.chatMessages,
      lastMessages: lastMessages ?? this.lastMessages,
      isLoadingUser: isLoadingUser ?? this.isLoadingUser,
    );
  }
}
