import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  WebViewController? _controller;
  String? privacyPolicyUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPrivacyPolicyUrl();
  }

  Future<void> _fetchPrivacyPolicyUrl() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('privacy_policy')
          .get();

      print("Document data: ${doc.data()}"); // Debug print
      if (!doc.exists) {
        await FirebaseFirestore.instance
            .collection('app_settings')
            .doc('privacy_policy')
            .set({
          'url': 'https://docs.google.com/document/d/default/preview',
        });
      }

      if (doc.data()?['url'] != null) {
        privacyPolicyUrl = doc.data()?['url'];

        _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(privacyPolicyUrl!));

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        debugPrint("Privacy policy URL not found in Firestore");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching privacy policy URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (privacyPolicyUrl == null)
          ? const Center(child: Text("Privacy policy not available"))
          : WebViewWidget(controller: _controller!),
    );
  }
}
