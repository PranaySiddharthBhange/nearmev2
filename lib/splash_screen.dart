import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'location_service.dart';
import 'bottom_navigation_bar.dart';
import 'auth_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Check location services
    if (!await Geolocator.isLocationServiceEnabled()) {
      await _showErrorDialog(
        'Location services are disabled. Please enable them to continue.',
        actionLabel: 'Enable',
        onAction: Geolocator.openLocationSettings,
      );
      return _initializeApp(); // Retry after enabling location
    }

    // Handle location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        await _showErrorDialog(
          'Location permission is permanently denied. Enable it in settings to continue.',
          actionLabel: 'Open Settings',
          onAction: openAppSettings,
        );
        return _initializeApp(); // Retry after enabling permission
      }
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      try {
        await LocationService.getUserLocation(); // Fetch user's location
        _navigateToNextScreen(); // Proceed to the next screen
      } catch (e) {
        await _showErrorDialog('Failed to fetch location: $e');
      }
    }
  }

  void _navigateToNextScreen() {
    User? user = FirebaseAuth.instance.currentUser;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => user != null ? const BottomNavBar() :  AuthScreen(),
      ),
    );
  }

  Future<void> _showErrorDialog(
      String message, {
        String? actionLabel,
        Future<void> Function()? onAction,
      }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [
          if (actionLabel != null && onAction != null)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await onAction(); // Perform the action
              },
              child: Text(actionLabel, style: const TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/animations/loading.json',
          width: screenWidth,
        ),
      ),
    );
  }
}
