import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime sentTime;
  final MessageType messageType;
  final bool isRead;

  const ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.sentTime,
    required this.content,
    required this.messageType,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        receiverId: json['receiverId'] as String,
        senderId: json['senderId'] as String,
        sentTime: (json['sentTime'] as Timestamp)
            .toDate(), // Casting Timestamp to DateTime
        content: json['content'] as String,
        messageType: MessageType.fromJson(json['messageType'] as String),
        isRead: json['isRead'] as bool? ??
            false, // Set to false if isRead is not provided
      );

  Map<String, dynamic> toJson() => {
        'receiverId': receiverId,
        'senderId': senderId,
        'sentTime': Timestamp.fromDate(
            sentTime), // Converting DateTime to Timestamp for Firestore compatibility
        'content': content,
        'messageType': messageType.toJson(),
        'isRead': isRead, // Including isRead in the serialized map
      };

  ChatMessage copyWith({bool? isRead}) {
    return ChatMessage(
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      sentTime: sentTime,
      messageType: messageType,
      isRead: isRead ?? this.isRead,
    );
  }
}

enum MessageType {
  text,
  image;

  static MessageType fromJson(String json) => MessageType.values
      .firstWhere((type) => type.toString().split('.').last == json);

  String toJson() => toString().split('.').last;
}
