import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:intl/intl.dart';
import 'package:nearme/global_location.dart';

class WorkingCreateCurrent extends StatefulWidget {
  final String CollectionREf;
  const WorkingCreateCurrent({Key? key, required this.CollectionREf}) : super(key: key);

  @override
  State<WorkingCreateCurrent> createState() => _WorkingCreateCurrentState();
}

class _WorkingCreateCurrentState extends State<WorkingCreateCurrent> {
  String? uid;
  String createdAt = "Curent Location";
  bool isLoading = false;
  bool showErrors = false;

  final descController = TextEditingController();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final experienceController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final whatsappNumberController = TextEditingController();
  final emailController = TextEditingController();
  final photoUrlController = TextEditingController();
  final geo = GeoFlutterFire();
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getCurrentUserUid();
    createdLocation();
  }

  void getCurrentUserUid() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    setState(() {
      uid = user?.uid;
    });
  }

  Future<void> createdLocation() async {
    if (globalLatitude != null && globalLongitude != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(globalLatitude!, globalLongitude!);
      Placemark placemark = placemarks.first;
      setState(() {
        createdAt = '${placemark.name}, ${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
      });
    }
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool isNumber = false,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          errorText: showErrors && isRequired && controller.text.isEmpty ? '$label is required' : null,
        ),
        keyboardType: keyboardType,
        inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
      ),
    );
  }

  bool validateFields() {
    return !(nameController.text.isEmpty ||
        descController.text.isEmpty ||
        ageController.text.isEmpty ||
        experienceController.text.isEmpty ||
        mobileNumberController.text.isEmpty ||
        whatsappNumberController.text.isEmpty
    );}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Service")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildTextField(controller: nameController, label: 'Provider Name', isRequired: true),
            buildTextField(controller: descController, label: 'Description', isRequired: true),
            buildTextField(controller: ageController, label: 'Age', keyboardType: TextInputType.number, isNumber: true, isRequired: true),
            buildTextField(controller: experienceController, label: 'Experience (years)', keyboardType: TextInputType.number, isNumber: true, isRequired: true),
            buildTextField(controller: mobileNumberController, label: 'Mobile Number', keyboardType: TextInputType.phone, isRequired: true),
            buildTextField(controller: whatsappNumberController, label: 'WhatsApp Number', keyboardType: TextInputType.phone, isRequired: true),
            // Display location
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                "Service will be created at: $createdAt",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            // Submit button
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

                setState(() {
                  isLoading = true;
                });

                if (uid == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User not logged in')),
                  );
                  return;
                }

                GeoFirePoint myLocation = geo.point(latitude: globalLatitude!, longitude: globalLongitude!);
                await _firestore.collection('workers').add({
                  'position': myLocation.data,
                  'description': descController.text,
                  'createdOn': DateFormat.yMMMMd().format(DateTime.now()),
                  'createdAt': createdAt,
                  'createdById': uid!,
                  'category': widget.CollectionREf,
                  'exp': int.tryParse(experienceController.text) ?? 0,
                  'name': nameController.text,
                  'age': int.tryParse(ageController.text) ?? 0,
                  'mobileNumber': mobileNumberController.text,
                  'whatsappNumber': whatsappNumberController.text,
                });

                setState(() {
                  isLoading = false;
                });

                Navigator.pop(context);
              },
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Create"),
            ),
          ],
        ),
      ),
    );
  }
}
