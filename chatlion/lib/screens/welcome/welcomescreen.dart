import 'package:chatlion/screens/auth/singin_screen.dart';
import 'package:chatlion/screens/auth/singup_screen.dart';
import 'package:chatlion/widgets/custom_scaffold.dart';
import 'package:chatlion/widgets/welcome_button.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundImage: 'assets/background.jpg',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 20.0, top: 0.0),
            child: RichText(
              textAlign: TextAlign.start,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Welcome\n',
                    style: TextStyle(
                      fontSize: 45.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white, 
                    ),
                  ),
                  TextSpan(
                    text: '\nStart chatting with your friends !',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Expanded(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign in',
                      onTap: SignInScreen(),
                      color: Colors.transparent,
                      textColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign up',
                      onTap: SignUpScreen(),
                      color: Colors.white,
                      textColor: Color.fromARGB(255, 108, 63, 231),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
