// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geoflutterfire2/geoflutterfire2.dart';
// import 'package:intl/intl.dart';
//
// class WorkingCreateMap extends StatefulWidget {
//   final String collTitle;
//   final double latitudeCreate;
//   final double longitudeCreate;
//
//   const WorkingCreateMap({Key? key, required this.collTitle, required this.latitudeCreate, required this.longitudeCreate}) : super(key: key);
//
//   @override
//   State<WorkingCreateMap> createState() => _WorkingCreateMapState();
// }
//
// class _WorkingCreateMapState extends State<WorkingCreateMap> {
//
//   String? uid;
//
//   void getCurrentUserUid() {
//     FirebaseAuth auth = FirebaseAuth.instance;
//     User? user = auth.currentUser;
//
//     if (user != null) {
//       setState(() {
//         uid = user.uid;
//       });
//     } else {
//       setState(() {
//         uid = null;
//       });
//     }
//   }
//
//   String createdAt = "Unknown";
//   final nameController = TextEditingController();
//   final descController = TextEditingController();
//   final ageController = TextEditingController();
//   final experienceController = TextEditingController();
//   final mobileNumberController = TextEditingController();
//   final whatsappNumberController = TextEditingController();
//
//   final geo = GeoFlutterFire();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     getCurrentUserUid();
//     createdLocation();
//   }
//
//   Future<void> createdLocation() async {
//     List<Placemark> placemarks = await placemarkFromCoordinates(widget.latitudeCreate, widget.longitudeCreate);
//     Placemark placemark = placemarks[0];
//     setState(() {
//       createdAt = '${placemark.name}, ${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Create Shop"),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(labelText: 'Provider Name'),
//             ),
//             TextField(
//               controller: descController,
//               decoration: const InputDecoration(labelText: 'Description'),
//             ),
//             TextField(
//               controller: ageController,
//               decoration: const InputDecoration(labelText: 'Age'),
//               keyboardType: TextInputType.number,
//             ),
//             TextField(
//               controller: experienceController,
//               decoration: const InputDecoration(labelText: 'Experience (years)'),
//               keyboardType: TextInputType.number,
//             ),
//             TextField(
//               controller: mobileNumberController,
//               decoration: const InputDecoration(labelText: 'Mobile Number'),
//               keyboardType: TextInputType.phone,
//             ),
//             TextField(
//               controller: whatsappNumberController,
//               decoration: const InputDecoration(labelText: 'WhatsApp Number'),
//               keyboardType: TextInputType.phone,
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () async {
//                 GeoFirePoint myLocation = geo.point(latitude: widget.latitudeCreate, longitude: widget.longitudeCreate);
//
//                 DocumentReference newLocationRef = await _firestore.collection('workers').add({
//                   'name': nameController.text,
//                   'position': myLocation.data,
//                   'description': descController.text,
//                   'createdOn': DateFormat.yMMMMd().format(DateTime.now()),
//                   'createdAt': createdAt,
//                   'createdById': uid.toString(),
//                   'category': widget.collTitle,
//                   'exp': int.tryParse(experienceController.text) ?? 0,
//                   'age': int.tryParse(ageController.text) ?? 0,
//                   'mobileNumber': mobileNumberController.text,
//                   'whatsappNumber': whatsappNumberController.text,
//                 });
//
//                 Navigator.pop(context);
//               },
//               child: const Text("Create"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:intl/intl.dart';

class WorkingCreateMap extends StatefulWidget {
  final String collTitle;
  final double latitudeCreate;
  final double longitudeCreate;

  const WorkingCreateMap({Key? key, required this.collTitle, required this.latitudeCreate, required this.longitudeCreate}) : super(key: key);

  @override
  State<WorkingCreateMap> createState() => _WorkingCreateMapState();
}

class _WorkingCreateMapState extends State<WorkingCreateMap> {
  String? uid;
  bool showErrors = false;
  String createdAt = "Unknown";

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final ageController = TextEditingController();
  final experienceController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final whatsappNumberController = TextEditingController();

  final geo = GeoFlutterFire();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getCurrentUserUid();
    createdLocation();
  }

  void getCurrentUserUid() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });
    }
  }

  Future<void> createdLocation() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(widget.latitudeCreate, widget.longitudeCreate);
    Placemark placemark = placemarks[0];
    setState(() {
      createdAt = '${placemark.name}, ${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
    });
  }

  bool validateFields() {
    return !(nameController.text.isEmpty ||
        descController.text.isEmpty ||
        ageController.text.isEmpty ||
        experienceController.text.isEmpty ||
        mobileNumberController.text.isEmpty ||
        whatsappNumberController.text.isEmpty);
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          errorText: showErrors && controller.text.isEmpty ? '$label is required' : null,
        ),
        keyboardType: keyboardType,
        inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Service"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildTextField(controller: nameController, label: 'Provider Name'),
            buildTextField(controller: descController, label: 'Description'),
            buildTextField(controller: ageController, label: 'Age', keyboardType: TextInputType.number, isNumber: true),
            buildTextField(controller: experienceController, label: 'Experience (years)', keyboardType: TextInputType.number, isNumber: true),
            buildTextField(controller: mobileNumberController, label: 'Mobile Number', keyboardType: TextInputType.phone),
            buildTextField(controller: whatsappNumberController, label: 'WhatsApp Number', keyboardType: TextInputType.phone),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                "Service will be created at: $createdAt",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  showErrors = true;
                });

                if (!validateFields()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                GeoFirePoint myLocation = geo.point(latitude: widget.latitudeCreate, longitude: widget.longitudeCreate);
                await _firestore.collection('workers').add({
                  'name': nameController.text,
                  'position': myLocation.data,
                  'description': descController.text,
                  'createdOn': DateFormat.yMMMMd().format(DateTime.now()),
                  'createdAt': createdAt,
                  'createdById': uid.toString(),
                  'category': widget.collTitle,
                  'exp': int.tryParse(experienceController.text) ?? 0,
                  'age': int.tryParse(ageController.text) ?? 0,
                  'mobileNumber': mobileNumberController.text,
                  'whatsappNumber': whatsappNumberController.text,
                });

                Navigator.pop(context);
                Navigator.pop(context);

              },
              child: Row(
                children: [
                  const Text("Create"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
