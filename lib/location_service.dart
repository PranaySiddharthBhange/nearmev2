import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'global_location.dart';

class LocationService {
  static Future<void> getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(

    );

    globalLatitude = position.latitude;
    globalLongitude = position.longitude;

    List<Placemark> placemarks = await placemarkFromCoordinates(globalLatitude!, globalLongitude!);
    globalAddress = '${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country}';

  }
}
