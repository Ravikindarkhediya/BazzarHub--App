import 'dart:convert';
import 'package:flutter/services.dart';
import '../services/models/location/location_models.dart';

// Singleton implementation
class LocationRepository {

  LocationRepository._privateConstructor();
  static final LocationRepository instance = LocationRepository._privateConstructor();

  LocationData? _locationData;
  final Map<String, StateData> _stateMap = {};
  final Map<String, List<String>> _stateDistrictMap = {};
  final Map<String, Map<String, DistrictData>> _districtMap = {};

  Future<void> initialize() async {
    if (_locationData != null) return;
    final jsonString = await rootBundle.loadString('assets/data/india_locations.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    _locationData = LocationData.fromJson(jsonData);

    // Preparation for fast lookup
    for (final state in _locationData!.states) {
      _stateMap[state.state] = state;
      _stateDistrictMap[state.state] = state.districts.map((d) => d.district).toList();
      _districtMap[state.state] = {};
      for (final district in state.districts) {
        _districtMap[state.state]![district.district] = district;
      }
    }
  }

  List<String> getStates() {
    return _stateMap.keys.toList()..sort(_caseInsensitiveSort);
  }

  List<String>? getDistricts(String stateName) {
    return _stateDistrictMap[stateName]?.toList()?..sort(_caseInsensitiveSort);
  }

  DistrictData? getDistrictData(String stateName, String districtName) {
    return _districtMap[stateName]?[districtName];
  }

  List<String> getSubDistricts(String stateName, String districtName) {
    final district = getDistrictData(stateName, districtName);
    if (district == null || !district.hasSubDistricts) return [];
    return district.subDistricts!.map((s) => s.subDistrict).toList()..sort(_caseInsensitiveSort);
  }

  List<String> getVillages(String stateName, String districtName, [String? subDistrictName]) {
    final district = getDistrictData(stateName, districtName);
    if (district == null) return [];
    if (subDistrictName != null && district.hasSubDistricts) {
      if (district.subDistricts != null) {
        final matches = district.subDistricts!.where((s) => s.subDistrict == subDistrictName);
        if (matches.isNotEmpty) {
          return matches.first.villages.toList()..sort(_caseInsensitiveSort);
        }
      }
      return [];
    } else if (!district.hasSubDistricts && district.subDistricts != null) {
      final villages = district.subDistricts!.expand((sd) => sd.villages).toList();
      return villages..sort(_caseInsensitiveSort);
    }
    return [];
  }


  bool hasSubDistricts(String stateName, String districtName) {
    final district = getDistrictData(stateName, districtName);
    return district?.hasSubDistricts ?? false;
  }

  int _caseInsensitiveSort(String a, String b) =>
      a.toLowerCase().compareTo(b.toLowerCase());
}
