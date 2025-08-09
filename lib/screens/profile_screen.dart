import 'package:find_stuff/services/local/shared_prefrence.dart' show SharedPrefsHelper;
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? name;
  String? email;
  String? photo;

  @override
  void initState() {
    super.initState();
    getLocalData();
  }

  Future<void> getLocalData() async {
    final localName = await SharedPrefsHelper.getName();
    final localEmail = await SharedPrefsHelper.getEmail();
    final localPhoto = await SharedPrefsHelper.getImage();

    setState(() {
      name = localName ?? 'User';
      email = localEmail ?? 'Email not found';
      photo = localPhoto;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hi $name',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: (photo != null && photo!.isNotEmpty)
                    ? NetworkImage(photo!)
                    : const AssetImage('assets/profile_picture.png') as ImageProvider,
              ),
              const SizedBox(height: 20),
              Text(
                email ?? "Email not found",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
