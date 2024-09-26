import 'dart:convert';
import 'package:chatlion/screens/chat/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

const channel = AndroidNotificationChannel(
    'high_importance_channel', 'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true);

class NotificationsService {
  static const key =
      'AAAAeGakOHY:APA91bGY5p4zsQ5Wfmkweb4hABpkqXoJxx2IyBlJT8pX3_hNh6YXbiGF6mUBJZ-i2uGyQtYk1F51kHIZNh_QDRLrQeBTTuFcrHZATg-GQhzPs4XvLwH18tWuHkVXK48G-rb51Y8Ab56p';

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void _initLocalNotification() {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (response) {
      debugPrint(response.payload.toString());
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final styleInformation = BigTextStyleInformation(
      message.notification!.body.toString(),
      htmlFormatBigText: true,
      contentTitle: message.notification!.title,
      htmlFormatTitle: true,
    );
    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.max,
      styleInformation: styleInformation,
      priority: Priority.max,
      playSound: channel.playSound,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await flutterLocalNotificationsPlugin.show(0, message.notification!.title,
        message.notification!.body, notificationDetails,
        payload: message.data['body']);
  }

  Future<void> requestPermission() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  Future<void> getToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      _saveToken(token);
    }
  }

  Future<void> _saveToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'token': token}, SetOptions(merge: true));
    }
  }

  String receiverToken = '';

  Future<void> getReceiverToken(String? receiverId) async {
    if (receiverId != null) {
      final getToken = await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverId)
          .get();
      final data = getToken.data();
      if (data != null && data['token'] != null) {
        receiverToken = data['token'];
      } else {
        debugPrint('Token not found or document does not exist.');
        receiverToken = '';
      }
    } else {
      debugPrint('Receiver ID is null.');
    }
  }

  void firebaseNotification(context) {
    _initLocalNotification();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            userId: message.data['senderId'],
            chatId: '',
          ),
        ),
      );
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _showLocalNotification(message);
    });
  }

  Future<void> initializeNotifications(BuildContext context) async {
    await requestPermission();
    // ignore: use_build_context_synchronously
    firebaseNotification(context);
  }

  Future<void> sendNotification(
      {required String body, required String senderId}) async {
    if (receiverToken.isEmpty) {
      debugPrint('Receiver token is empty. Cannot send notification.');
      return;
    }

    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$key',
        },
        body: jsonEncode(<String, dynamic>{
          "to": receiverToken,
          'priority': 'high',
          'notification': <String, dynamic>{
            'body': body,
            'title': 'New Message!',
          },
          'data': <String, String>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            'senderId': senderId,
          }
        }),
      );
    } catch (e) {
      debugPrint('Failed to send notification: $e');
    }
  }
}
