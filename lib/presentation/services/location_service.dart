import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

import 'models/location/location_models.dart';

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
  static LocationService? _instance;
  LocationData? _locationData;

  LocationService._();

  factory LocationService() {
    _instance ??= LocationService._();
    return _instance!;
  }

  Future<void> loadLocationData() async {
    if (_locationData != null) return;

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/india_locations.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      _locationData = LocationData.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load location data: $e');
    }
  }

  List<String> getStates() {
    if (_locationData == null) return [];
    final states = _locationData!.states.map((e) => e.state).toList();
    states.sort(_caseInsensitiveSort);
    return states;
  }

  List<String> getDistricts(String stateName) {
    final state = _findState(stateName);
    if (state == null) return [];
    final districts = state.districts.map((e) => e.district).toList();
    districts.sort(_caseInsensitiveSort);
    return districts;
  }

  DistrictData? getDistrictData(String stateName, String districtName) {
    final state = _findState(stateName);
    if (state == null) return null;
    for (final district in state.districts) {
      if (district.district == districtName) return district;
    }
    return null;
  }

  List<String> getSubDistricts(String stateName, String districtName) {
    final districtData = getDistrictData(stateName, districtName);
    if (districtData == null || !districtData.hasSubDistricts) return [];
    final subDistricts =
        districtData.subDistricts!.map((e) => e.subDistrict).toList();
    subDistricts.sort(_caseInsensitiveSort);
    return subDistricts;
  }

  List<String> getVillages(
    String stateName,
    String districtName, [
    String? subDistrictName,
  ]) {
    final districtData = getDistrictData(stateName, districtName);
    if (districtData == null) return [];

    if (subDistrictName != null && districtData.hasSubDistricts) {
      final subDistrict = _findSubDistrict(districtData, subDistrictName);
      final villages = subDistrict?.villages ?? [];
      return _sortedCopy(villages);
    } else if (!districtData.hasSubDistricts &&
        (districtData.subDistricts ?? []).isNotEmpty) {
      final villages = districtData.subDistricts!
          .expand((s) => s.villages)
          .toList(growable: false);
      return _sortedCopy(villages);
    }

    return [];
  }

  bool hasSubDistricts(String stateName, String districtName) {
    final districtData = getDistrictData(stateName, districtName);
    return districtData?.hasSubDistricts ?? false;
  }

  StateData? _findState(String stateName) {
    if (_locationData == null) return null;
    for (final state in _locationData!.states) {
      if (state.state == stateName) return state;
    }
    return null;
  }

  SubDistrictData? _findSubDistrict(
    DistrictData district,
    String subDistrictName,
  ) {
    for (final subDistrict in district.subDistricts ?? []) {
      if (subDistrict.subDistrict == subDistrictName) {
        return subDistrict;
      }
    }
    return null;
  }

  List<String> _sortedCopy(List<String> source) {
    final copy = List<String>.from(source);
    copy.sort(_caseInsensitiveSort);
    return copy;
  }

  int _caseInsensitiveSort(String a, String b) =>
      a.toLowerCase().compareTo(b.toLowerCase());
}
