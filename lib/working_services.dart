
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:nearme/global_location.dart';
import 'package:nearme/working_create_current.dart';
import 'package:nearme/working_profile.dart';
import 'package:nearme/working_show_map.dart';

class WorkingServices extends StatefulWidget {
  final category;

  const WorkingServices({Key? key, required this.category}) : super(key: key);
  const WorkingServices.WorkingServicesShow({Key? key, required this.category})
      : super(key: key);

  @override
  State<WorkingServices> createState() => _WorkingServicesState();
}

String? uid;

class _WorkingServicesState extends State<WorkingServices> {
  double radius = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid;
  }

  void _changeRadius(bool increase) {
    setState(() {
      radius = increase ? radius + 1 : (radius > 0 ? radius - 1 : 0);
    });
  }

  void _startTimer(bool increase) {
    _timer = Timer.periodic(
      Duration(milliseconds: 150),
          (timer) => _changeRadius(increase),
    );
  }

  void _stopTimer() => _timer?.cancel();

  @override
  Widget build(BuildContext context) {
    final geo = GeoFlutterFire();
    GeoFirePoint center = geo.point(
      latitude: globalLatitude!,
      longitude: globalLongitude!,
    );

    var collectionReference = FirebaseFirestore.instance.collection('workers');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkingCreateCurrent(
                  CollectionREf: widget.category.title,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.location_searching),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkingShowMap(
                  collTitle: widget.category.title,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildRadiusControls(),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: geo
            .collection(collectionRef: collectionReference)
            .within(center: center, radius: radius, field: 'position'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final matchingDocs = snapshot.data!
              .where((doc) => doc['category'] == widget.category.title)
              .toList();

          return ListView.builder(
            itemCount: matchingDocs.length,
            itemBuilder: (context, index) {
              return ServiceCard(data: matchingDocs[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildRadiusControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        RadiusButton(
          radius: radius,
          onPressed: () {
            setState(() => radius = 1);
            _stopTimer();
          },
        ),
        SizedBox(height: 15),
        RadiusControlButton(
          icon: Icons.add,
          onPressed: () => _changeRadius(true),
          onLongPress: () => _startTimer(true),
          onLongPressEnd: (_) => _stopTimer(),
        ),
        SizedBox(height: 12),
        RadiusControlButton(
          icon: Icons.remove,
          onPressed: () => _changeRadius(false),
          onLongPress: () => _startTimer(false),
          onLongPressEnd: (_) => _stopTimer(),
        ),
      ],
    );
  }
}

class RadiusButton extends StatelessWidget {
  final double radius;
  final VoidCallback onPressed;

  const RadiusButton({required this.radius, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.green[50],
      onPressed: onPressed,
      child: Text(radius.toStringAsFixed(1)),
    );
  }
}

class RadiusControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final VoidCallback onLongPress;
  final void Function(LongPressEndDetails) onLongPressEnd;

  const RadiusControlButton({
    required this.icon,
    required this.onPressed,
    required this.onLongPress,
    required this.onLongPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onLongPressEnd: onLongPressEnd,
      child: FloatingActionButton(
        backgroundColor: Colors.green[50],
        onPressed: onPressed,
        child: Icon(icon),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final DocumentSnapshot data;

  const ServiceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    String userId = data.get('createdById').toString();
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkingProfile(data: data),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Profile Image in Square Frame
              _buildProfileImage(userId),

              SizedBox(width: 10),

              // Right Side Content (Name and Experience)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  _buildName(userId),
                  SizedBox(height: 5),

                  // Experience
                  _buildInfoRow('Experience', '${data.get('exp')} years'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(String userId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.grey[200],
            ),
            child: const CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.grey[200],
            ),
            child: Icon(Icons.error, color: Colors.red),
          );
        }

        var userDoc = snapshot.data!;
        String profileImageUrl = userDoc.get('profile_image') ?? ''; // Get profile image URL

        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            image: profileImageUrl.isNotEmpty
                ? DecorationImage(image: NetworkImage(profileImageUrl), fit: BoxFit.cover)
                : DecorationImage(image: AssetImage('assets/default_profile.png') as ImageProvider, fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  Widget _buildName(String userId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            'Loading...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Error loading name',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          );
        }

        var userDoc = snapshot.data!;
        String name = userDoc.get('name') ?? 'No Name';

        return Text(
          name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          Text(
            info,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
