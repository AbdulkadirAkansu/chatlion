import 'package:chatlion/riverpod/auth_provider.dart';
import 'package:chatlion/riverpod/chat_provider.dart';
import 'package:chatlion/screens/welcome/welcomescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authProvider.notifier).fetchCurrentUser();
    final chatState = ref.watch(chatProvider);
    final authState = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: InkWell(
                onTap: () => ref
                    .read(chatProvider.notifier)
                    .updateProfilePicture(context),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                      chatState.user?.image ?? 'default_image_url'),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              authState.username,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              authState.currentUser?.email ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            buildSettingsListTile(
              icon: Icons.person,
              title: 'Hesap',
              onTap: () {},
            ),
            buildSettingsListTile(
              icon: Icons.devices,
              title: 'Bağlı Cihazlar',
              onTap: () {},
            ),
            buildSettingsListTile(
              icon: Icons.favorite,
              title: "Bağış Yap",
              onTap: () {},
            ),
            buildSettingsListTile(
              icon: Icons.visibility,
              title: 'Görünüm',
              onTap: () {},
            ),
            buildSettingsListTile(
              icon: Icons.chat,
              title: 'Sohbetler',
              onTap: () {},
            ),
            buildSettingsListTile(
              icon: Icons.camera_alt,
              title: 'Hikayeler',
              onTap: () {},
            ),
            buildSettingsListTile(
              icon: Icons.notifications,
              title: 'Bildirimler',
              onTap: () {},
            ),
            buildSettingsListTile(
              icon: Icons.lock,
              title: 'Gizlilik',
              onTap: () {},
            ),
            buildSettingsListTile(
              icon: Icons.data_usage,
              title: 'Veri ve depolama',
              onTap: () {},
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepPurpleAccent
                    .withOpacity(0.8), 
                elevation: 1,
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5), 
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Logout'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildSettingsListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
