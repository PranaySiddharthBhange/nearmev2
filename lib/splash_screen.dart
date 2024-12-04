// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geolocator/geolocator.dart';
// import 'location_service.dart';
// import 'bottom_navigation_bar.dart';
// import 'auth_screen.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   String? _errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeApp();
//   }
//
//   Future<void> _initializeApp() async {
//     try {
//       // Check location permission and attempt to get user location
//       if (await _handleLocationPermission()) {
//         await LocationService.getUserLocation();
//       } else {
//         _errorMessage = 'Location permission denied. Enable it in settings.';
//       }
//     } catch (e) {
//       _errorMessage = 'An error occurred while fetching location: $e';
//     }
//
//     _navigateToNextScreen();
//   }
//
//   Future<bool> _handleLocationPermission() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//
//     if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
//       permission = await Geolocator.requestPermission();
//     }
//
//     // Return true only if permission is granted
//     return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
//   }
//
//   void _navigateToNextScreen() {
//     // If there’s an error, show an alert dialog and prevent navigation
//     if (_errorMessage != null) {
//       _showErrorDialog(_errorMessage!);
//     } else {
//       // Check Firebase Auth state and navigate accordingly
//       User? user = FirebaseAuth.instance.currentUser;
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//           builder: (context) => user != null ? const BottomNavBar() :  AuthScreen(),
//         ),
//       );
//     }
//   }
//
//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Error'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(), // Close dialog
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'location_service.dart';
import 'bottom_navigation_bar.dart';
import 'auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Check location permission and attempt to get user location
      if (await _handleLocationPermission()) {
        await LocationService.getUserLocation();
      } else {
        _errorMessage = 'Location permission denied. Enable it in settings.';
      }
    } catch (e) {
      _errorMessage = 'An error occurred while fetching location: $e';
    }

    _navigateToNextScreen();
  }

  Future<bool> _handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    // Return true only if permission is granted
    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  void _navigateToNextScreen() {
    // If there’s an error, show an alert dialog and prevent navigation
    if (_errorMessage != null) {
      _showErrorDialog(_errorMessage!);
    } else {
      // Check Firebase Auth state and navigate accordingly
      User? user = FirebaseAuth.instance.currentUser;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => user != null ? const BottomNavBar() : AuthScreen(),
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close dialog
            child: const Text('OK'),
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
          'assets/animations/loading.json', // Replace with your Lottie file
          width: screenWidth*2,
        ),
      ),
    );
  }
}
