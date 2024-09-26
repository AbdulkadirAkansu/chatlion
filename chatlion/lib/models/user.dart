class ChatUser {
  final String uid;
  final String name;
  final String email;
  final String image;
  final DateTime lastActive;
  final bool isOnline;
  final String username;

  const ChatUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.image,
    required this.lastActive,
    this.isOnline = false,
    required this.username,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
        uid: json['uid'] ?? 'default_id',
        name: json['name'] ?? 'default_name',
        email: json['email'] ?? 'default_email',
        image: json['image'] ?? 'default_image',
        isOnline: json['isOnline'] ?? false,
        lastActive: json['lastActive']?.toDate() ?? DateTime.now(),
        username: json['username'] ?? 'default_username',
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'image': image,
        'isOnline': isOnline,
        'lastActive': lastActive,
        'username': username,
      };
}
