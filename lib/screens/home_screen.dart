
import 'package:find_stuff/constants.dart';
import 'package:find_stuff/models/categories.dart' show Category;
import 'package:find_stuff/screens/add_item.dart' show AddFoundItemPage;
import 'package:find_stuff/screens/login_screen.dart';
import 'package:find_stuff/screens/profile_screen.dart';
import 'package:find_stuff/services/local/shared_prefrence.dart'
    show SharedPrefsHelper;
import 'package:find_stuff/widgets/custom_text.dart' show CustomText;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? selectedCategoryId;

  Stream<List<Category>> getCategories() {
    return FirebaseFirestore.instance
        .collection('categories')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Category.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<QuerySnapshot> getFoundItemsStream() {
    if (selectedCategoryId == null) {
      // Return empty stream until a category is selected or return all items if you prefer
      return FirebaseFirestore.instance
          .collection('found_items')
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
    return FirebaseFirestore.instance
        .collection('found_items')
        .where('categoryId', isEqualTo: selectedCategoryId)
        //.orderBy('createdAt', descending: true) // comment this out temporarily
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddFoundItemPage());
        },
        child: const Icon(Icons.add),
      ),
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
                      const SnackBar(
                        content: Text('Logout failed, please try again'),
                      ),
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
            if (_scaffoldKey.currentState != null &&
                !_scaffoldKey.currentState!.isDrawerOpen) {
              _scaffoldKey.currentState!.openDrawer();
            }
          },
          child: const SizedBox(height: 50, width: 50, child: Icon(Icons.menu)),
        ),
        title: const Text("Find Stuff"),
        automaticallyImplyLeading: true,
        centerTitle: true,
        actions: const [
          SizedBox(height: 50, width: 50, child: Icon(Icons.settings)),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(Constants.defaultPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(text: "Categories", isBold: true),
              SizedBox(height: Constants.defaultMargin),
              StreamBuilder<List<Category>>(
                stream: getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No categories found"));
                  }

                  final categories = snapshot.data!;
                  return SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = category.id == selectedCategoryId;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategoryId = category.id;
                            });
                          },
                          child: Card(
                            color: isSelected
                                ? Constants.primaryColor
                                : Colors.white,
                            child: Container(
                              width: 140,
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.category,
                                    size: 40,
                                    color: isSelected
                                        ? Colors.white
                                        : Constants.primaryColor,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    category.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: Constants.defaultMargin),
              CustomText(text: "Items", isBold: true),
              SizedBox(height: Constants.defaultMargin),
              SizedBox(
                height: 500,
                child: StreamBuilder<QuerySnapshot>(
                  stream: getFoundItemsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No items found"));
                    }

                    final items = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final data = items[index];
                        final imageUrl = data['imageUrl'] as String?;
                        return ListTile(
                          leading: (imageUrl != null && imageUrl.isNotEmpty)
                              ? Image.network(
                                  imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image_not_supported),
                          title: Text(data['title'] ?? 'No title'),
                          subtitle: Text(data['address'] ?? ''),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

