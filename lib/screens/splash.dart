import 'package:find_stuff/auth/login.dart' show AuthPage;
import 'package:find_stuff/screens/home_screen.dart' show HomeScreen;
import 'package:find_stuff/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  goToLoginScreen() {
    Future.delayed(const Duration(seconds: 2), () {
      final token = _auth.currentUser!.getIdToken();
      if (token != null) {
        Get.offAll(() => HomeScreen());
      } else {
        Get.offAll(() => AuthPage());
      }
    });
  }

  @override
  void initState() {
    goToLoginScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Find your lost items')],
        ),
      ),
    );
  }
}
