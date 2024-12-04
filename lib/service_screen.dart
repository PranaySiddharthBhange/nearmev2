import 'package:flutter/material.dart';

class ServiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Services'),
      ),
      body: Center(
        child: Text(
          'Service Screen',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
