import 'package:chatlion/riverpod/auth_provider.dart';
import 'package:chatlion/riverpod/models/auth_state.dart';
import 'package:chatlion/screens/auth/singup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatlion/widgets/forgot_password.dart';
import 'package:chatlion/theme/theme.dart';


class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: screenSize.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(screenSize.width * 0.01),
                child: Image.asset(
                  'assets/login.gif',
                  fit: BoxFit.contain,
                  height: screenSize.height * 0.3,
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    screenSize.width * 0.1,
                    screenSize.height * 0.05,
                    screenSize.width * 0.1,
                    screenSize.height * 0.02,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                  ),
                  child: _buildFormFields(context, ref, screenSize, authState),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields(BuildContext context, WidgetRef ref, Size screenSize, AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            'Welcome back',
            style: TextStyle(
              fontSize: screenSize.width * 0.08,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF7B68EE),
            ),
          ),
        ),
        SizedBox(height: screenSize.height * 0.04),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter Email',
            hintStyle: const TextStyle(color: Colors.black26),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            errorText: authState.emailErrorMessage,
          ),
          onChanged: (value) {
            ref.read(authProvider.notifier).setEmail(value);
            ref.read(authProvider.notifier).setEmailErrorMessage(
                ref.read(authProvider.notifier).validateEmail(value));
          },
        ),
        SizedBox(height: screenSize.height * 0.025),
        TextFormField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter Password',
            hintStyle: const TextStyle(color: Colors.black26),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            errorText: authState.passwordErrorMessage,
          ),
          onChanged: (value) {
            ref.read(authProvider.notifier).setPassword(value);
            ref.read(authProvider.notifier).setPasswordErrorMessage(
                ref.read(authProvider.notifier).validatePassword(value));
          },
        ),
        SizedBox(height: screenSize.height * 0.015),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const ForgotPasswordDialog(),
                );
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: lightTheme().primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenSize.height * 0.04),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).signIn(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: lightTheme().primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Login',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        SizedBox(height: screenSize.height * 0.05),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Don\'t have an account? ',
              style: TextStyle(color: Colors.black45),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
              },
              child: Text(
                'Sign up',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: lightTheme().primaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
