import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final Widget child;
  final String backgroundImage;

  const CustomScaffold({
    super.key,
    required this.child,
    required this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              backgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 100.0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/animation.gif',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: child,
          ),
        ],
      ),
    );
  }
}
