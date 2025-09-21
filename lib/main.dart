import 'package:find_stuff/screens/splash.dart' show SplashScreen;
import 'package:find_stuff/server_bluttoth.dart';
import 'package:find_stuff/services/local/local_notifications.dart';
import 'package:find_stuff/services/notifications.dart' show FirebaseNotificationManager;
import 'package:find_stuff/test.dart' show ReferralHome;
import 'package:find_stuff/testnew.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
 // Stripe.publishableKey = "";

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseNotificationManager().initialize();
  await createNotificationChannel();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {

  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(),
    );
  }
}

