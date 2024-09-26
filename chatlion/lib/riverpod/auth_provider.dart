import 'package:chatlion/riverpod/models/auth_state.dart';
import 'package:chatlion/screens/chat/chats.screen.dart';
import 'package:chatlion/screens/welcome/welcomescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier()
      : super(AuthState(currentUser: FirebaseAuth.instance.currentUser));

  late String _email;
  late String _password;
  late String _username;
  String? _emailErrorMessage;
  String? _passwordErrorMessage;
  bool _isLoggedIn = false;
  User? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;
  String get email => _email;
  String get password => _password;
  String get username => _username;
  String? get emailErrorMessage => _emailErrorMessage;
  String? get passwordErrorMessage => _passwordErrorMessage;
  User? get safeCurrentUser => FirebaseAuth.instance.currentUser;

  void setUsername(String username) {
    _username = username;
  }

  void setEmail(String email) {
    _email = email;
    state = state.copyWith(email: email);
  }

  void setPassword(String password) {
    _password = password;
  }

  String? validateEmail(String email) {
    if (!email.contains('@')) {
      return 'Invalid email format';
    }
    return null;
  }

  String? validatePassword(String password) {
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<bool> userExists() async {
    return (await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get())
        .exists;
  }

Future<void> fetchCurrentUser() async {
  User? firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser != null) {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      state = state.copyWith(
          currentUser: firebaseUser,
          username: userData['username'],  
          email: firebaseUser.email,
          isLoggedIn: true);
    }
  }
}

Future<void> signUp(BuildContext context) async {
  try {
    final UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _email,
      password: _password,
    );
    final User? user = userCredential.user;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'username': _username,
        'email': _email,
      });
      try {
        await user.sendEmailVerification();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doğrulama e-postası gönderildi.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Doğrulama e-postası gönderilemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _isLoggedIn = true;
      fetchCurrentUser();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ChatsScreen()));
    }
  } catch (error) {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kayıt başarısız: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  Future<void> checkEmailVerificationStatus(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      user = FirebaseAuth.instance.currentUser;

      if (user!.emailVerified) {
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const ChatsScreen()),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email is not verified yet.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User is not authenticated.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> signIn(BuildContext context) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);
      final user = userCredential.user;
      if (user != null && user.emailVerified) {
        _isLoggedIn = true;
        await fetchCurrentUser();
        state = state.copyWith(isLoggedIn: true, currentUser: user);
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const ChatsScreen()),
        );
      } else if (user != null && !user.emailVerified) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify your email to continue.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        await FirebaseAuth.instance.signOut();
        state = state.copyWith(isLoggedIn: false);
      }
    } catch (error) {
      // ignore: avoid_print
      print('Sign in failed: $error');
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      _isLoggedIn = false;
      state = state.copyWith(isLoggedIn: false, currentUser: null);
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    } catch (error) {
      // ignore: avoid_print
      print('Sign out failed: $error');
    }
  }

  Future<void> resetPassword(BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      _isLoggedIn = true;
    } catch (error) {
      // ignore: avoid_print
      print('Password reset failed: $error');
    }
  }

  void setEmailErrorMessage(String? message) {
    _emailErrorMessage = message;
    state = state.copyWith(emailErrorMessage: message);
  }

  void setPasswordErrorMessage(String? message) {
    _passwordErrorMessage = message;
  }

  Future<bool> checkUserLoggedIn(WidgetRef ref) async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }
}
