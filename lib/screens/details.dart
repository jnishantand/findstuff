import 'package:find_stuff/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailsPage extends StatelessWidget {
  final List<String> imageUrls;
  final String itemName;
  final String location;
  final String uploaderUserId;
  final String uploaderPhoneNumber;
  final String description;


  const ItemDetailsPage({
    Key? key,
    required this.imageUrls,
    required this.itemName,
    required this.location,
    required this.uploaderUserId,
    required this.uploaderPhoneNumber,
    required this.description,
  }) : super(key: key);

  void _callUploader() async {

    print("Calling uploader: $uploaderPhoneNumber");
    final Uri callUri = Uri(scheme: 'tel', path: uploaderPhoneNumber);
    if (await canLaunchUrl(callUri)) {
     // await launchUrl(callUri);
    } else {
      // Handle error if cannot launch phone dialer
      debugPrint('Could not launch $callUri');
    }
  }

  void _goToProfile(BuildContext context) {
    // Navigate to profile screen
    // You need to implement this screen and navigation
    Navigator.pushNamed(context, '/profile', arguments: uploaderUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Item Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    imageUrls[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.broken_image)),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomText(text: itemName, isBold: true),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(location),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
              ),
              margin: EdgeInsets.all(18.0),
              padding: EdgeInsets.all(18.0),
              width: MediaQuery.of(context).size.width,
              child: Text(
                description ?? 'No description available.',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.justify,
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.person),
                    label: const Text('View Profile'),
                    onPressed: () => _goToProfile(context),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.call),
                    label: Text('${uploaderPhoneNumber??"NA"} '),
                    onPressed: _callUploader,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
