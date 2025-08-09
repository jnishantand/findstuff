import 'package:find_stuff/services/local/shared_prefrence.dart'
    show SharedPrefsHelper;
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
    getLocalData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'HI ${name??"User"}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/profile_picture.png'),
                ),
                SizedBox(height: 20),
                Text(
                  email ?? "Name not found",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getLocalData() async {
    await SharedPrefsHelper.getName().then((val) {
      if (val != null) {
        name = val.toString();
      }
    });
    await SharedPrefsHelper.getEmail().then((val) {
      if (val != null) {
        email = val.toString();
      }
    });
    await SharedPrefsHelper.getImage().then((val) {
      if (val != null) {
        photo = val.toString();
      }
    });
    setState(() {});
  }
}
