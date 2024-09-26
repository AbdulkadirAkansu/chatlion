import 'package:firebase_auth/firebase_auth.dart';

class AuthState {
  final String? emailErrorMessage;
  final String? passwordErrorMessage;
  final bool isLoggedIn;
  final String email;
  final String username;
  final User? currentUser;

  AuthState({
    this.emailErrorMessage,
    this.passwordErrorMessage,
    this.isLoggedIn = false,
    this.email = '',
    this.username = '',
    this.currentUser,
  });

  AuthState copyWith({
    String? emailErrorMessage,
    String? passwordErrorMessage,
    bool? isLoggedIn,
    String? email,
    String? username,
    User? currentUser,
  }) {
    return AuthState(
      emailErrorMessage: emailErrorMessage ?? this.emailErrorMessage,
      passwordErrorMessage: passwordErrorMessage ?? this.passwordErrorMessage,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      email: email ?? this.email,
      username: username ?? this.username,
      currentUser: currentUser ?? this.currentUser,
    );
  }
}
