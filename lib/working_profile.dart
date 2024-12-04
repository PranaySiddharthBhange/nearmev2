import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';

class WorkingProfile extends StatefulWidget {
  final DocumentSnapshot data;

  const WorkingProfile({Key? key, required this.data}) : super(key: key);

  @override
  State<WorkingProfile> createState() => _WorkingProfileState();
}

class _WorkingProfileState extends State<WorkingProfile> {
  String? uid;
  List<String> imageUrls = []; // To store uploaded image URLs
  final ImagePicker _picker = ImagePicker();

  // Function to get the current user's UID
  void getCurrentUserUid() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });
    }
  }

  // Fetch already uploaded images from Firestore
  Future<void> fetchUploadedImages() async {
    final images = await FirebaseFirestore.instance
        .collection('workers')
        .doc(widget.data.id)
        .collection('images')
        .get();

    setState(() {
      imageUrls = images.docs.map((doc) => doc['url'].toString()).toList();
    });
  }

  // Function to upload image to Firebase Storage and save the URL to Firestore
  Future<void> uploadImage() async {
    // Pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    File file = File(image.path);
    String fileName = basename(file.path);

    try {
      // Upload image to Firebase Storage
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('worker_images/${widget.data.id}/$fileName');
      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      // Get the image URL after uploading
      String imageUrl = await snapshot.ref.getDownloadURL();

      // Save the URL to Firestore
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(widget.data.id)
          .collection('images')
          .add({'url': imageUrl});

      // Update the UI with the new image URL
      setState(() {
        imageUrls.add(imageUrl);
      });
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  // Function to launch the phone dialer
  void _launchPhone(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  // Function to launch WhatsApp
  void _launchWhatsApp(String whatsappNumber) async {
    final url = 'https://wa.me/+91$whatsappNumber';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  // Function to launch Google Maps with the user's location
  void _launchMap(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserUid();
    fetchUploadedImages(); // Fetch any uploaded images
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.data['name'];
    final String mobileNumber = widget.data['mobileNumber'];
    final String whatsappNumber = widget.data['whatsappNumber'];
    final GeoPoint location = widget.data['position']['geopoint'];
    final bool isCreator = uid == widget.data['createdById'];

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Contact $name", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            if (mobileNumber.isNotEmpty) ...[
              ElevatedButton.icon(
                icon: Icon(Icons.phone),
                label: Text("Call $mobileNumber"),
                onPressed: () => _launchPhone(mobileNumber),
              ),
              SizedBox(height: 10),
            ],
            if (whatsappNumber.isNotEmpty) ...[
              ElevatedButton.icon(
                icon: Icon(Icons.whatshot),
                label: Text("WhatsApp $whatsappNumber"),
                onPressed: () => _launchWhatsApp(whatsappNumber),
              ),
              SizedBox(height: 10),
            ],
            ElevatedButton.icon(
              icon: Icon(Icons.map),
              label: Text("View on Map"),
              onPressed: () => _launchMap(location.latitude, location.longitude),
            ),
            SizedBox(height: 30),

            // If the current user is the creator, show the option to upload photos
            if (isCreator)
              ElevatedButton.icon(
                icon: Icon(Icons.upload),
                label: Text("Upload Work Photos"),
                onPressed: uploadImage,
              ),

            // Display uploaded images
            if (imageUrls.isNotEmpty) ...[
              SizedBox(height: 20),
              Text("Work Photos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(imageUrls[index], fit: BoxFit.cover);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
