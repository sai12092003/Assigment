import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'login.dart';  // For CupertinoPageRoute, for smooth transition

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 1.0;  // Start with full opacity

  @override
  void initState() {
    super.initState();
    // Fade out the splash screen after 2 seconds and navigate to login screen
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _opacity = 0.0;  // Fade out the logo
      });

      // After fading out, navigate to the LoginScreen
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const Login()),  // Smooth transition to LoginScreen
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[800],
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 2),  // Duration of fade-out effect
          child: SizedBox(
            width: 150,  // Adjust the width to make the image smaller
            height: 150, // Adjust the height to make the image smaller
            child: Image.asset('assets/logo.png'),  // Replace with your logo image path
          ),
        ),
      ),
    );
  }
}
