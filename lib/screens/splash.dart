import 'package:find_stuff/auth/login.dart' show AuthPage;
import 'package:find_stuff/screens/home_screen.dart' show HomeScreen;
import 'package:find_stuff/services/local/shared_prefrence.dart' show SharedPrefsHelper;
import 'package:find_stuff/widgets/custom_text.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // mark final

  void goToLoginScreen() {
    Future.delayed(const Duration(seconds: 2), () async {
      if (_auth.currentUser != null) {
        try {
          final token = await _auth.currentUser!.getIdToken();
          // token.toString() is never null, so no need for ??
          await SharedPrefsHelper.saveUserDetails(
            image: _auth.currentUser!.photoURL ?? "",
            name: _auth.currentUser!.displayName ?? "",
            email: _auth.currentUser!.email ?? "",
            token: token.toString(),
            id: _auth.currentUser!.uid ?? "",
            phone: _auth.currentUser!.phoneNumber ?? "",
          );
        } catch (e) {
          // Replace print with a proper logger or remove
          // For now, you can use debugPrint which is recommended
          debugPrint("Error in getting token: $e");
        }
        if (mounted) {
          Get.offAll(() => HomeScreen());
        }

      } else {
        if (mounted) {
          Get.offAll(() => AuthPage());
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    goToLoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            Image.asset(
              'assets/images/app_logo.png',
              width: 100,
              height: 100,
            ),
            CustomText(text: 'Find your lost items',isBold: true,)],
        ),
      ),
    );
  }
}
