import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:nearme/global_location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nearme/working_create_map.dart';

class WorkingShowMap extends StatefulWidget {
  final String collTitle;
  const WorkingShowMap({super.key, required this.collTitle});

  @override
  State<WorkingShowMap> createState() => WorkingShowMapState();
}
var mapLatitude=globalLatitude;
var mapLongitude=globalLongitude;

class WorkingShowMapState extends State<WorkingShowMap> {



  String locationName = '';



  final Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(globalLatitude!, globalLongitude!),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(mapLatitude!, mapLongitude!),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  final geo = GeoFlutterFire();


  TextEditingController _searchController = TextEditingController();


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
            mini: true,
            onPressed: _goToTheLake,
            child: const Icon(Icons.location_searching),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  suffixIcon: IconButton(
                    onPressed: () {
                      _performSearch(_searchController.text);
                    },
                    icon: Icon(Icons.search),
                  ),
                ),
                onSubmitted: (value) {
                  _performSearch(value);
                },
              ),
            ),
            Expanded(
              child: GoogleMap(
                onTap: (coLoc) async {
                  print("Letses teh resulu'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''$coLoc)");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkingCreateMap(
                        collTitle: widget.collTitle, // Replace with your collection reference
                        latitudeCreate: coLoc.latitude,         // Replace with your latitude
                        longitudeCreate: coLoc.longitude,       // Replace with your longitude
                      ),
                    ),
                  );

                },
                mapType: MapType.hybrid,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
  Future<void> _performSearch(String searchQuery) async {
    try {
      final List<Location> locations = await locationFromAddress(searchQuery);
      if (locations.isNotEmpty) {
        final Location location = locations.first;
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLng(
          LatLng(location.latitude!, location.longitude!),
        ));
      }
    } catch (e) {
      print('Error searching for location: $e');
    }
  }
}