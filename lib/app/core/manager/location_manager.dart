import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationManager with ChangeNotifier {
  static final LocationManager _instance = LocationManager._internal();
  factory LocationManager() => _instance;
  LocationManager._internal();

  double _latitude = 0.0;
  double _longitude = 0.0;

  String _city = '';
  String _state = '';
  String _country = '';
  String _address = '';

  double get latitude => _latitude;
  double get longitude => _longitude;
  String get city => _city;
  String get state => _state;
  String get country => _country;
  String get address => _address;

  // -----------------------------------------------------

  Future<void> requestLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      print("Location services disabled");
      return;
    }

    if (await isLocationGranted()) {
      await _getCurrentLocation();
    } else {
      // await _requestPermissions();
    }
  }

  Future<bool> isLocationGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // Future<void> _requestPermissions() async {
  //   await Permission.location.request();
  //   if (await isLocationGranted()) {
  //     await _getCurrentLocation();
  //   }
  // }

  // -----------------------------------------------------

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      List<Placemark> placemarks =
      await placemarkFromCoordinates(_latitude, _longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        _city = place.locality ?? '';
        _state = place.administrativeArea ?? '';
        _country = place.country ?? '';

        _address =
        "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      }

      notifyListeners();
    } catch (e) {
      print("❌ Error getting location: $e");
    }
  }
}
