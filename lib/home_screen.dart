import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nearme/splash_screen.dart';
import 'global_location.dart';
class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    // Navigate back to SplashScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SplashScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context), // Pass the context here
          ),
        ],
      ),
      body: Center(
        child: user != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to Near Me!'),
            SizedBox(height: 20),
            Text('User Information:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Email: ${user.email}'), // Display user's email
            Text('User ID: ${user.uid}'), // Display user's ID
            Text('Latitude: ${globalLatitude ?? "Not Available"}'),
            Text('Longitude: ${globalLongitude ?? "Not Available"}'),
            Text('Address: ${globalAddress ?? "Not Available"}'),

          ],
        )
            : Text('No user is currently logged in.'),
      ),
    );
  }
}
