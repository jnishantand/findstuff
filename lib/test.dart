import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';


class ReferralHome extends StatefulWidget {
  @override
  _ReferralHomeState createState() => _ReferralHomeState();
}

class _ReferralHomeState extends State<ReferralHome> {
  String deviceId = Uuid().v4(); // Unique device identifier
  String referralCode = '';
  String rewardStatus = '';
  final String serverUrl = "http://10.0.2.2:3000"; // Android emulator

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Deferred Referral Demo")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Device ID: $deviceId", style: TextStyle(fontSize: 14)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: generateReferralCode,
              child: Text("Generate My Referral Code"),
            ),
            SizedBox(height: 10),
            Text("Referral Code: $referralCode", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: shareReferralCode,
              child: Text("Share Referral Code"),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: applyReferral,
              child: Text("Simulate Signup / Apply Referral"),
            ),
            SizedBox(height: 10),
            Text("Reward Status: $rewardStatus", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // Generate referral code for current device
  Future<void> generateReferralCode() async {
    final response = await http.post(
      Uri.parse("$serverUrl/generateReferralCode"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": deviceId}),
    );
    final data = jsonDecode(response.body);
    setState(() {
      referralCode = data['referralCode'];
    });
  }

  // Share referral code using native share
  void shareReferralCode() {
    if (referralCode.isNotEmpty) {
      Share.share("Use my referral code: $referralCode to sign up!");
    }
  }

  // Apply referral (simulate new user signup)
  Future<void> applyReferral() async {
    final response = await http.post(
      Uri.parse("$serverUrl/applyReferralCode"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"newUserId": "newUser_${Uuid().v4()}", "deviceId": deviceId}),
    );
    final data = jsonDecode(response.body);
    setState(() {
      rewardStatus = data['success'] ? "Reward Applied: ${data['reward']}" : data['message'];
    });
  }
}
