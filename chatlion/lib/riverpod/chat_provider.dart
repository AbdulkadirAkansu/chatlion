import 'package:chatlion/models/chat_message.dart';
import 'package:chatlion/models/user.dart';
import 'package:chatlion/riverpod/models/chat_state.dart';
import 'package:chatlion/services/firebase_storage_service.dart';
import 'package:chatlion/services/media_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier()
      : super(ChatState(
          users: [],
          user: null,
          messages: [],
          search: [],
          chatMessages: {},
          lastMessages: {},
          isLoadingUser: false,
        ));

  static final firestore = FirebaseFirestore.instance;
  ScrollController scrollController = ScrollController();

  Future<void> loadUsersAndLastMessages() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    state = state.copyWith(isLoadingUser: true);
    firestore.collection('users').snapshots().listen((userSnapshot) {
      var users = userSnapshot.docs
          .map((doc) => ChatUser.fromJson(doc.data()))
          .toList();
      for (var user in users) {
        var chatId = getChatId(currentUser.uid, user.uid);
        firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('sentTime', descending: true)
            .limit(1)
            .snapshots()
            .listen((messageSnapshot) {
          if (messageSnapshot.docs.isNotEmpty) {
            var lastMessage =
                ChatMessage.fromJson(messageSnapshot.docs.first.data());
            state = state.copyWith(
                lastMessages: {...state.lastMessages, user.uid: lastMessage},
                users: users,
                isLoadingUser: false);
          }
        });
      }
    });
  }

  Future<void> updateProfilePicture(BuildContext context) async {
    Uint8List? imageData = await MediaService.pickImage();
    if (imageData == null) return;
    final user = FirebaseAuth.instance.currentUser;
    final userProfile = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    final username = userProfile.data()!['username'] as String;
    String storagePath = "userProfileImages/$username.png";
    String imageUrl =
        await FirebaseStorageService.uploadImage(imageData, storagePath);
    await updateProfileImage(user.uid, imageUrl);
  }

  Future<ChatUser?> setActiveChatUser(String userId) async {
    try {
      var userDocument = await firestore.collection('users').doc(userId).get();
      if (userDocument.exists) {
        return ChatUser.fromJson(userDocument.data()!);
      } else {}
    } catch (e) {
      // ignore: avoid_print
      print("Error setting active user: $e");
    }

    return null;
  }

  Stream<List<ChatMessage>> getMessagesForUser(String userId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Stream.empty();

    String chatId = getChatId(currentUser.uid, userId);
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromJson(doc.data()))
            .toList());
  }

  void getMessagesForChat(String chatId) {
    getMessagesForUser(chatId).listen((messageList) {
      state = state.copyWith(messages: messageList);
    });
  }

  void getMessages(String receiverId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String chatId = getChatId(currentUser.uid, receiverId);
      firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('sentTime', descending: true)
          .snapshots()
          .listen((snapshot) {
        state = state.copyWith(
          chatMessages: {
            ...state.chatMessages,
            receiverId: snapshot.docs
                .map((doc) => ChatMessage.fromJson(doc.data()))
                .toList(),
          },
        );
      });
    }
  }

  void getAllUsers() {
    firestore
        .collection('users')
        .orderBy('lastActive', descending: true)
        .snapshots()
        .listen((snapshot) {
      state = state.copyWith(
        users:
            snapshot.docs.map((doc) => ChatUser.fromJson(doc.data())).toList(),
      );
    });
  }

  void getUserById(String userId) {
    firestore.collection('users').doc(userId).snapshots().listen((snapshot) {
      state = state.copyWith(
        user: snapshot.data() != null
            ? ChatUser.fromJson(snapshot.data()!)
            : null,
      );
    });
  }

  Future<List<ChatUser>> searchUser(String username) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      var users = querySnapshot.docs
          .map((doc) => ChatUser.fromJson(doc.data()))
          .toList();

      state = state.copyWith(search: users);
      return users;
    } catch (e) {
      // ignore: avoid_print
      print("An error occurred while searching users: $e");
      return [];
    }
  }

  void scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  static String getChatId(String userId1, String userId2) {
    return userId1.hashCode <= userId2.hashCode
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  static Future<void> updateProfileImage(String uid, String imageUrl) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'image': imageUrl,
    });
  }

  static Future<void> createUser({
    required String name,
    required String image,
    required String email,
    required String uid,
    required String username,
  }) async {
    final user = ChatUser(
      uid: uid,
      email: email,
      name: name,
      image: image,
      isOnline: true,
      lastActive: DateTime.now(),
      username: username,
    );
    await firestore.collection('users').doc(uid).set(user.toJson());
  }

  static Future<void> addTextMessage({
    required String content,
    required String receiverId,
  }) async {
    final senderId = FirebaseAuth.instance.currentUser!.uid;
    final chatId = getChatId(senderId, receiverId);
    final message = ChatMessage(
      content: content,
      sentTime: DateTime.now(),
      receiverId: receiverId,
      messageType: MessageType.text,
      senderId: senderId,
    );
    // ignore: avoid_print
    print(
        "FirebaseChatService: Adding text message with receiverId: $receiverId");

    await firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toJson());
  }

  static Future<void> addImageMessage({
    required String receiverId,
    required Uint8List file,
  }) async {
    final senderId = FirebaseAuth.instance.currentUser!.uid;
    final chatId = getChatId(senderId, receiverId);
    final image = await FirebaseStorageService.uploadImage(
        file, 'image/chat/${DateTime.now()}');
    final message = ChatMessage(
      content: image,
      sentTime: DateTime.now(),
      receiverId: receiverId,
      messageType: MessageType.image,
      senderId: senderId,
    );
    await firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toJson());
  }
}
