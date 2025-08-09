import 'package:find_stuff/screens/login_screen.dart';
import 'package:find_stuff/screens/profile_screen.dart';
import 'package:find_stuff/services/local/shared_prefrence.dart' show SharedPrefsHelper;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Get.to(() => const ProfileScreen());
                },
              ),
              ListTile(
                leading: const Icon(Icons.door_back_door_outlined),
                title: const Text('Logout'),
                onTap: () async {
                  try {
                    await SharedPrefsHelper.clearAll();
                    await _auth.signOut();
                    Get.offAll(() => const LoginScreen());
                  } catch (e) {
                    debugPrint("Error during logout: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logout failed, please try again')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            if (_scaffoldKey.currentState != null && !_scaffoldKey.currentState!.isDrawerOpen) {
              _scaffoldKey.currentState!.openDrawer();
            }
          },
          child: const SizedBox(
            height: 50,
            width: 50,
            child: Icon(Icons.menu),
          ),
        ),
        title: const Text("Find Stuff"),
        automaticallyImplyLeading: true,
        centerTitle: true,
        actions: const [
          SizedBox(height: 50, width: 50, child: Icon(Icons.settings)),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to the Home Screen'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add your button action here
              },
              child: const Text('Click Me'),
            ),
          ],
        ),
      ),
    );
  }
}
