import 'package:chatlion/riverpod/auth_provider.dart';
import 'package:chatlion/screens/chat/chats.screen.dart';
import 'package:chatlion/screens/welcome/welcomescreen.dart';
import 'package:chatlion/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatlion/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: AnaUygulama()));
}

class AnaUygulama extends ConsumerWidget {
  const AnaUygulama({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationService = NotificationsService();
    notificationService.initializeNotifications(context);

    return MaterialApp(
      title: 'ChatLion',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<bool>(
        future: ref.read(authProvider.notifier).checkUserLoggedIn(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          return snapshot.data ?? false ? const ChatsScreen() : const WelcomeScreen();
        },
      ),
    );
  }
}
