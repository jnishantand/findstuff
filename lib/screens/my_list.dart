import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:find_stuff/constants.dart';
import 'package:find_stuff/widgets/custom_text.dart';
import 'package:find_stuff/screens/details.dart';

class MyFoundItemsPage extends StatelessWidget {
  const MyFoundItemsPage({super.key});

  Stream<QuerySnapshot> getUserItemsStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('found_items')
        .where('userId', isEqualTo: userId) // ✅ Filter by logged-in user
        //.orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("My Posts"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(Constants.defaultPadding),
        child: StreamBuilder<QuerySnapshot>(
          stream: getUserItemsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text("No posts found."),
              );
            }

            final items = snapshot.data!.docs;

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final data = items[index];
                final imageUrl = data['imageUrl'] as String?;

                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemDetailsPage(
                          imageUrls: imageUrl != null && imageUrl.isNotEmpty
                              ? [imageUrl]
                              : [],
                          itemName: data['title'] ?? 'No title',
                          location: data['address'] ?? 'NA',
                          uploaderUserId: data['userId'] ?? '',
                          uploaderPhoneNumber: data['contact']??"NA",
                          description: data['description'] ?? 'No description',
                        ),
                      ),
                    );
                  },
                  leading: (imageUrl != null && imageUrl.isNotEmpty)
                      ? Image.network(
                    imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.image_not_supported),
                  title: CustomText(
                    text: data['title'] ?? 'No title',
                    isBold: true,
                  ),
                  subtitle: Text(data['address'] ?? ''),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
