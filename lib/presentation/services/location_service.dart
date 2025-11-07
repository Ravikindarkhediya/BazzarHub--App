import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

class LocationService {
  /// Get current address safely with user permission handling
  Future<String> getCurrentAddress(BuildContext context) async {
    // Step 1: Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 🔹 Show dialog to enable GPS
      final shouldOpenSettings = await _showEnableLocationDialog(context);
      if (shouldOpenSettings == true) {
        await Geolocator.openLocationSettings();
      }
      // Return a message instead of throwing error
      throw Exception("Please enable GPS and try again.");
    }

    // Step 2: Check and request permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied by user.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await _showPermissionDeniedDialog(context);
      throw Exception("Location permission permanently denied.");
    }

    // Step 3: Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Step 4: Convert coordinates to address
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark place = placemarks.first;
    String address =
        "${place.street}, ${place.locality}, ${place.subAdministrativeArea}, ${place.country}";
    return address;
  }

  // 📍 Dialog to ask user to enable GPS
  Future<bool?> _showEnableLocationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enable Location"),
        content: const Text(
            "Your GPS is turned off. Would you like to enable it to get your current location?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Enable"),
          ),
        ],
      ),
    );
  }

  // ⚙️ Dialog if permission is permanently denied
  Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "You have permanently denied location permission. Please enable it from your app settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
