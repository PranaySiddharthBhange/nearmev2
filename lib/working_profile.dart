import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:nearme/working_services.dart';
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
  List<String> imageUrls = [];
  final ImagePicker _picker = ImagePicker();

  void getCurrentUserUid() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });
    }
  }

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

  Future<void> uploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    File file = File(image.path);
    String fileName = basename(file.path);

    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('worker_images/${widget.data.id}/$fileName');
      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      String imageUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('workers')
          .doc(widget.data.id)
          .collection('images')
          .add({'url': imageUrl});

      setState(() {
        imageUrls.add(imageUrl);
      });
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  void _launchPhone(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }




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
    fetchUploadedImages();
  }

  @override
  Widget build(BuildContext context) {
    final String mobileNumber = widget.data['mobileNumber'];
    final String whatsappNumber = widget.data['whatsappNumber'];
    final GeoPoint location = widget.data['position']['geopoint'];
    final bool isCreator = uid == widget.data['createdById'];

    return Scaffold(
      appBar: AppBar(
        title: Text("Name"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Contact Information",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    SizedBox(height: 16),
                    if (mobileNumber.isNotEmpty) ...[
                      ElevatedButton.icon(
                        icon: Icon(Icons.phone),
                        label: Text("Call $mobileNumber"),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _launchPhone(mobileNumber),
                      ),
                      SizedBox(height: 10),
                    ],
                    if (whatsappNumber.isNotEmpty) ...[
                      ElevatedButton.icon(
                        icon: Icon(Icons.chat),
                        label: Text("WhatsApp $whatsappNumber"),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          var whatsappUrl = "whatsapp://send?phone=+91$whatsappNumber&text=${Uri.encodeComponent("Hello")}";

                          launch(whatsappUrl);
                        },
                      ),
                      SizedBox(height: 10),
                    ],
                    ElevatedButton.icon(
                      icon: Icon(Icons.map),
                      label: Text("View on Map"),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _launchMap(location.latitude, location.longitude),
                    ),
                  ],
                ),
              ),
              if (isCreator)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          "Manage Work Photos",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: Icon(Icons.upload),
                          label: Text("Upload Photos"),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: uploadImage,
                        ),
                      ],
                    ),
                  ),
                ),
              if (imageUrls.isNotEmpty) ...[
                SizedBox(height: 20),
                Text(
                  "Work Photos",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: Icon(Icons.rate_review),
                  label: Text("Write a Review"),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewPage(workerId: widget.data.id),
                      ),
                    );
                  },
                ),
                SizedBox(height: 10),

                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrls[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),


              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ReviewPage extends StatefulWidget {
  final String workerId;

  const ReviewPage({Key? key, required this.workerId}) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int selectedRating = 0;
  final TextEditingController reviewController = TextEditingController();
  List<Map<String, dynamic>> reviews = [];

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    final reviewSnapshot = await FirebaseFirestore.instance
        .collection('workers')
        .doc(widget.workerId)
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      reviews = reviewSnapshot.docs
          .map((doc) => {
        'name': doc['name'] ?? 'Anonymous',
        'rating': doc['rating'],
        'review': doc['review'],
        'timestamp': doc['timestamp'],
      })
          .toList();
    });
  }

  Future<void> submitReview(int rating, String reviewText) async {
    if (rating == 0 || reviewText.isEmpty) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text("Please provide a rating and review.")),
      );
      return;
    }

    final newReview = {
      'name': 'User', // Replace with actual user name
      'rating': rating,
      'review': reviewText,
      'timestamp': Timestamp.now(),
    };

    await FirebaseFirestore.instance
        .collection('workers')
        .doc(widget.workerId)
        .collection('reviews')
        .add(newReview);

    setState(() {
      reviews.insert(0, newReview);
    });

    reviewController.clear();
    setState(() => selectedRating = 0);

    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      SnackBar(content: Text("Review submitted successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reviews"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Review Input Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Write a Review",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            selectedRating > index ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedRating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    TextField(
                      controller: reviewController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Write your review",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () =>
                          submitReview(selectedRating, reviewController.text.trim()),
                      child: Text("Submit Review"),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Reviews Display Section
            Expanded(
              child: reviews.isEmpty
                  ? Center(child: Text("No reviews yet"))
                  : ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Row(
                        children: [
                          Text(
                            review['name'],                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                          Row(
                            children: List.generate(5, (starIndex) {
                              return Icon(
                                starIndex < (review['rating'] ?? 0)
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 18,
                              );
                            }),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Text(review['review'] ?? ""),
                          SizedBox(height: 5),
                          Text(
                            review['timestamp'] != null
                                ? (review['timestamp'] as Timestamp)
                                .toDate()
                                .toString()
                                : '',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
