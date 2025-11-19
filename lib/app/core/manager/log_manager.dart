import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../../presentation/services/api_service.dart';
import 'location_manager.dart';

class LogManager {
  static Map<String, dynamic>? _apiData;
  static bool _loaded = false;

  // -----------------------------------------------------
  // Call IP API only ONCE & store JSON
  // -----------------------------------------------------

  static Future<void> initialize() async {
    if (_loaded) return;

    try {
      final response =
      await http.get(Uri.parse("https://ipapi.co/json"));

      if (response.statusCode == 200) {
        _apiData = jsonDecode(response.body);
        _loaded = true;
      }
    } catch (e) {
      print("IP API Error: $e");
    }
  }

  // -----------------------------------------------------
  // Helper: get with fallback (LocationManager → API → default)
  // -----------------------------------------------------

  static T getField<T>(String key, T defaultValue) {
    final loc = LocationManager();

    try {
      switch (key) {
        case "city":
          return (loc.city.isNotEmpty
              ? loc.city
              : _apiData?["city"] ?? defaultValue) as T;

        case "state":
          return (loc.state.isNotEmpty
              ? loc.state
              : _apiData?["region"] ?? defaultValue) as T;

        case "country":
          return (loc.country.isNotEmpty
              ? loc.country
              : _apiData?["country_name"] ?? defaultValue) as T;

        case "latitude":
          return (loc.latitude != 0.0
              ? loc.latitude
              : _apiData?["latitude"] ?? defaultValue) as T;

        case "longitude":
          return (loc.longitude != 0.0
              ? loc.longitude
              : _apiData?["longitude"] ?? defaultValue) as T;

        case "ip":
          return (_apiData?["ip"] ?? defaultValue) as T;

        default:
          return (_apiData?[key] ?? defaultValue) as T;
      }
    } catch (e) {
      debugPrint("Value parse error: $e");
      return defaultValue;
    }
  }

  // -----------------------------------------------------
  // Marketplace View Payload
  // -----------------------------------------------------
  static Future<Map<String, dynamic>> buildMarketplaceViewPayload(
      String listingId) async {
    await LogManager.initialize();

    return {
      "listingId": listingId,
      "platform": "web",
      "deviceInfo": "Windows 11, Chrome 120",

      "location": {
        "city": getField("city", ""),
        "state": getField("state", ""),
        "country": getField("country", ""),
        "location": {
          "latitude": getField("latitude", 0.0),
          "longitude": getField("longitude", 0.0),
        }
      },

      "viewerIP": getField("ip", "")
    };
  }

  // -----------------------------------------------------
  // NEW View Payload (if required)
  // -----------------------------------------------------
  Future<Map<String, dynamic>> buildNewViewPayload(
      String listingId) async {
    await LogManager.initialize();

    return {
      "listingId": listingId,
      "timestamp": DateTime.now().toIso8601String(),
      "viewerIP": getField("ip", ""),
      "location": {
        "city": getField("city", ""),
        "state": getField("state", ""),
        "country": getField("country", ""),
      }
    };
  }

  static Future<void> trackMarketplaceView(String listingId) async {
    try {
      var services = await getApiClient();
      final payload = await buildMarketplaceViewPayload(listingId);
      var response = await services.trackMarketplaceView(payload);
      if (response.data.status) {
        debugPrint("View logged successfully");
      }
    } on DioException catch (e) {
      debugPrint("Dio error: $e");
    } catch (error) {
      debugPrint("Error: $error");
    }
  }

}
