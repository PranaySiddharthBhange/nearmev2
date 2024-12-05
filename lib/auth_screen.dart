// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
//
// import 'package:nearme/bottom_navigation_bar.dart';
//
// class AuthScreen extends StatefulWidget {
//   @override
//   _AuthScreenState createState() => _AuthScreenState();
// }
//
// class _AuthScreenState extends State<AuthScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _nameController = TextEditingController();
//
//   String _errorMessage = '';
//   bool _isSignUp = true;
//   File? _pickedImage;
//
//   Future<void> _submit() async {
//     setState(() {
//       _errorMessage = '';
//     });
//
//     if (_emailController.text.isEmpty ||
//         _passwordController.text.isEmpty ||
//         (_isSignUp && _nameController.text.isEmpty)) {
//       setState(() {
//         _errorMessage = 'Please fill in all fields.';
//       });
//       return;
//     }
//
//     try {
//       UserCredential userCredential;
//       if (_isSignUp) {
//         userCredential = await _auth.createUserWithEmailAndPassword(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//         );
//
//         // Upload profile image and get its URL
//         String imageUrl = await _uploadProfileImage(userCredential.user!.uid);
//
//         // Save user data in Firestore
//         await _firestore.collection('users').doc(userCredential.user!.uid).set({
//           'name': _nameController.text.trim(),
//           'email': _emailController.text.trim(),
//           'password': _passwordController.text.trim(), // Store password safely only for testing
//           'created_at': Timestamp.now(),
//           'profile_image': imageUrl,
//           'created_by': userCredential.user!.uid,
//
//         });
//       } else {
//         userCredential = await _auth.signInWithEmailAndPassword(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//         );
//       }
//
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//           builder: (context) => BottomNavBar(),
//         ),
//       );
//     } on FirebaseAuthException catch (e) {
//       setState(() {
//         _errorMessage = _handleFirebaseAuthError(e);
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'An error occurred. Please try again.';
//       });
//       print('Error: $e');
//     }
//   }
//
//   Future<String> _uploadProfileImage(String uid) async {
//     if (_pickedImage == null) {
//       // Return default image URL if no image is selected
//       return 'https://picsum.photos/200';
//     }
//     final storageRef = _storage.ref().child('profile_images').child('$uid.jpg');
//     await storageRef.putFile(_pickedImage!);
//     return await storageRef.getDownloadURL();
//   }
//
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _pickedImage = File(pickedFile.path);
//       });
//     }
//   }
//
//   String _handleFirebaseAuthError(FirebaseAuthException e) {
//     switch (e.code) {
//       case 'user-not-found':
//         return 'No user found with this email.';
//       case 'wrong-password':
//         return 'Incorrect password.';
//       case 'email-already-in-use':
//         return 'Email is already in use.';
//       case 'invalid-email':
//         return 'Invalid email address.';
//       default:
//         return e.message ?? 'An unknown error occurred.';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_isSignUp ? 'Sign Up' : 'Login'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               if (_isSignUp)
//                 TextField(
//                   controller: _nameController,
//                   decoration: InputDecoration(labelText: 'Name'),
//                 ),
//               TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(labelText: 'Email'),
//               ),
//               TextField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(labelText: 'Password'),
//                 obscureText: true,
//               ),
//               SizedBox(height: 20),
//               if (_isSignUp)
//                 Column(
//                   children: [
//                     CircleAvatar(
//                       radius: 40,
//                       backgroundImage: _pickedImage != null
//                           ? FileImage(_pickedImage!)
//                           : NetworkImage('https://picsum.photos/200')
//                       as ImageProvider,
//                     ),
//                     TextButton.icon(
//                       onPressed: _pickImage,
//                       icon: Icon(Icons.image),
//                       label: Text('Upload Profile Image'),
//                     ),
//                   ],
//                 ),
//               if (_errorMessage.isNotEmpty)
//                 Text(
//                   _errorMessage,
//                   style: TextStyle(color: Colors.red),
//                 ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _submit,
//                 child: Text(_isSignUp ? 'Sign Up' : 'Login'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     _isSignUp = !_isSignUp; // Toggle between login and signup
//                   });
//                 },
//                 child: Text(_isSignUp
//                     ? 'Already have an account? Login'
//                     : 'Create an account'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nearme/bottom_navigation_bar.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  String _errorMessage = '';
  bool _isSignUp = true;
  File? _pickedImage;

  Future<void> _submit() async {
    setState(() {
      _errorMessage = '';
    });

    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        (_isSignUp && _nameController.text.isEmpty)) {
      setState(() {
        _errorMessage = 'Please fill in all fields.';
      });
      return;
    }

    try {
      UserCredential userCredential;
      if (_isSignUp) {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Upload profile image and get its URL
        String imageUrl = await _uploadProfileImage(userCredential.user!.uid);

        // Save user data in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'created_at': Timestamp.now(),
          'profile_image': imageUrl,
          'created_by': userCredential.user!.uid,
        });
      } else {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BottomNavBar(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _handleFirebaseAuthError(e);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
      print('Error: $e');
    }
  }

  Future<String> _uploadProfileImage(String uid) async {
    if (_pickedImage == null) {
      return 'https://picsum.photos/200';
    }
    final storageRef = _storage.ref().child('profile_images').child('$uid.jpg');
    await storageRef.putFile(_pickedImage!);
    return await storageRef.getDownloadURL();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'Email is already in use.';
      case 'invalid-email':
        return 'Invalid email address.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isSignUp ? 'Create Account' : 'Welcome Back',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 16),
                if (_isSignUp)
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                if (_isSignUp) SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                if (_isSignUp)
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: _pickedImage != null
                              ? FileImage(_pickedImage!)
                              : const NetworkImage('https://picsum.photos/200')
                          as ImageProvider,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Tap to upload profile image'),
                    ],
                  ),
                SizedBox(height: 16),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_isSignUp ? 'Sign Up' : 'Login',style:
                    TextStyle(color: Colors.white),),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignUp = !_isSignUp;
                    });
                  },
                  child: Text(
                    _isSignUp
                        ? 'Already have an account? Login'
                        : 'Create an account',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
