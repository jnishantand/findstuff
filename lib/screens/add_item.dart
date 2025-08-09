import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AddFoundItemPage extends StatefulWidget {
  const AddFoundItemPage({super.key});

  @override
  State<AddFoundItemPage> createState() => _AddFoundItemPageState();
}

class _AddFoundItemPageState extends State<AddFoundItemPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCategoryId;
  File? pickedImage;
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final addressController = TextEditingController();
  bool isLoading = false;

  Future<void> requestPermissions() async {
    await [
      Permission.photos,
      Permission.camera,
      Permission.storage,
    ].request();
  }

  Future<void> pickImage() async {
    await requestPermissions();
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75, // compress for faster uploads
    );
    if (pickedFile != null) {
      setState(() => pickedImage = File(pickedFile.path));
    }
  }

  Future<String> uploadImage(File image) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('found_items')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> submitItem() async {
    if (!_formKey.currentState!.validate() || selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String? imageUrl;
      if (pickedImage != null) {
        imageUrl = await uploadImage(pickedImage!);
      }

      await FirebaseFirestore.instance.collection('found_items').add({
        'categoryId': selectedCategoryId,
        'title': titleController.text.trim(),
        'description': descController.text.trim(),
        'address': addressController.text.trim(),
        'lat': null,
        'lng': null,
        'imageUrl': imageUrl ?? '', // empty if no image
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item added successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Found Item")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // CATEGORY DROPDOWN
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("No categories found. Add some first.");
                  }
                  final categories = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    value: selectedCategoryId,
                    hint: const Text("Select Category"),
                    items: categories.map((doc) {
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(doc['name']),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedCategoryId = value),
                    validator: (value) => value == null ? "Select category" : null,
                  );
                },
              ),
              const SizedBox(height: 10),

              // TITLE
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Item Title"),
                validator: (v) => v!.isEmpty ? "Enter title" : null,
              ),
              const SizedBox(height: 10),

              // DESCRIPTION
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (v) => v!.isEmpty ? "Enter description" : null,
                maxLines: 2,
              ),
              const SizedBox(height: 10),

              // ADDRESS
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Address"),
                validator: (v) => v!.isEmpty ? "Enter address" : null,
              ),
              const SizedBox(height: 10),

              // IMAGE PICKER
              pickedImage == null
                  ? TextButton.icon(
                icon: const Icon(Icons.image),
                label: const Text("Pick Image"),
                onPressed: pickImage,
              )
                  : Column(
                children: [
                  Image.file(pickedImage!, height: 150),
                  TextButton.icon(
                    icon: const Icon(Icons.change_circle),
                    label: const Text("Change Image"),
                    onPressed: pickImage,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // SUBMIT BUTTON
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: submitItem,
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}