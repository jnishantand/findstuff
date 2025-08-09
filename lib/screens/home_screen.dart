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
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
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
                leading: Icon(Icons.person),
                title: Text('Profile'),
                onTap: () {
                  Get.to(ProfileScreen());
                },
              ),
              ListTile(
                leading: Icon(Icons.door_back_door_outlined),
                title: Text('Logout'),
                onTap: () async{
                 try{
                   await SharedPrefsHelper.clearAll();
                   await _auth.signOut();
                   Get.offAll(LoginScreen());
                 }catch(e){
                    print("Error during logout: $e");
                 }
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: InkWell(
          onTap: (){
            _scaffoldKey.currentState!.openDrawer();
          },
          child: SizedBox(

              height: 50, width: 50, child: Icon(Icons.menu)),
        ),
        title: Text("Find Stuff"),
        automaticallyImplyLeading: true,
        centerTitle: true,
        actions: [SizedBox(height: 50, width: 50, child: Icon(Icons.settings))],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to the Home Screen'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add your button action here
              },
              child: Text('Click Me'),
            ),
          ],
        ),
      ),
    );
  }
}
