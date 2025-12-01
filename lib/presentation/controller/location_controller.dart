import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocationController extends GetxController {
  // ✅ Observable Location data
  final RxList<Map<String, dynamic>> _locationsData = <Map<String, dynamic>>[].obs;
  final RxList<String> statesList = <String>[].obs;
  final RxList<String> districtsList = <String>[].obs;
  final RxList<String> talukasList = <String>[].obs;
  final RxList<String> villagesList = <String>[].obs;

  // ✅ Observable selected values
  final Rx<String?> selectedState = Rx<String?>(null);
  final Rx<String?> selectedDistrict = Rx<String?>(null);
  final Rx<String?> selectedTaluka = Rx<String?>(null);
  final Rx<String?> selectedVillage = Rx<String?>(null);

  // ✅ Observable loading states
  final RxBool isLoadingDistricts = false.obs;
  final RxBool isLoadingTalukas = false.obs;
  final RxBool isLoadingVillages = false.obs;
  final RxBool isInitialized = false.obs;

  // ✅ Computed getters
  bool get canSelectDistrict => selectedState.value != null;
  bool get canSelectTaluka => selectedDistrict.value != null;
  bool get canSelectVillage => selectedTaluka.value != null;

  bool get isLocationComplete {
    return selectedState.value != null &&
        selectedDistrict.value != null &&
        selectedTaluka.value != null &&
        selectedVillage.value != null &&
        selectedVillage.value!.isNotEmpty;
  }

  // ✅ Lifecycle - Called when controller is initialized
  @override
  void onInit() {
    super.onInit();
    loadLocationsData();
    debugPrint('🎯 LocationController initialized');
  }

  // ✅ Lifecycle - Called when controller is closed
  @override
  void onClose() {
    debugPrint('🔴 LocationController closed');
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────
  // INITIALIZE LOCATION DATA
  // ─────────────────────────────────────────────────────────────
  Future<void> loadLocationsData() async {
    if (isInitialized.value) return;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/india_locations.json',
      );
      _locationsData.value = List<Map<String, dynamic>>.from(
        json.decode(jsonString),
      );

      final seen = <String>{};
      statesList.value = _locationsData
          .map((e) => e['state'] as String)
          .where((s) => seen.add(s))
          .toList()
        ..sort();

      isInitialized.value = true;
      debugPrint('✅ Location data loaded: ${statesList.length} states');
    } catch (e) {
      debugPrint('❌ Location load error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // PRE-FILL EXISTING LOCATION (for Edit Mode)
  // ─────────────────────────────────────────────────────────────
  Future<void> initializeWithUserLocation({
    String? state,
    String? district,
    String? taluka,
    String? village,
  }) async {
    await loadLocationsData();

    if (state != null && state.isNotEmpty && statesList.contains(state)) {
      selectedState.value = state;
      await loadDistricts(state, clearSelection: false);

      if (district != null &&
          district.isNotEmpty &&
          districtsList.contains(district)) {
        selectedDistrict.value = district;
        await loadTalukas(state, district, clearSelection: false);

        if (taluka != null &&
            taluka.isNotEmpty &&
            talukasList.contains(taluka)) {
          selectedTaluka.value = taluka;
          await loadVillages(state, district, taluka, clearSelection: false);

          if (village != null && village.isNotEmpty) {
            selectedVillage.value = village;
          }
        }
      }
    }

    debugPrint('✅ User location initialized');
  }

  // ─────────────────────────────────────────────────────────────
  // LOAD DISTRICTS
  // ─────────────────────────────────────────────────────────────
  Future<void> loadDistricts(String state, {bool clearSelection = true}) async {
    isLoadingDistricts.value = true;

    districtsList.clear();
    talukasList.clear();
    villagesList.clear();

    if (clearSelection) {
      selectedDistrict.value = null;
      selectedTaluka.value = null;
      selectedVillage.value = null;
    }

    try {
      final stateData = _locationsData.firstWhere(
            (e) => e['state'] == state,
        orElse: () => <String, dynamic>{},
      );

      if (stateData.isNotEmpty) {
        final districts = stateData['districts'] as List;
        final seen = <String>{};
        districtsList.value = districts
            .map<String>((d) => d['district'] as String)
            .where((d) => seen.add(d))
            .toList()
          ..sort();

        debugPrint('✅ Loaded ${districtsList.length} districts');
      }
    } catch (e) {
      debugPrint('❌ Error loading districts: $e');
    } finally {
      isLoadingDistricts.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LOAD TALUKAS (SUB-DISTRICTS)
  // ─────────────────────────────────────────────────────────────
  Future<void> loadTalukas(
      String state,
      String district,
      {bool clearSelection = true}
      ) async {
    isLoadingTalukas.value = true;

    talukasList.clear();
    villagesList.clear();

    if (clearSelection) {
      selectedTaluka.value = null;
      selectedVillage.value = null;
    }

    try {
      final stateData = _locationsData.firstWhere(
            (e) => e['state'] == state,
        orElse: () => <String, dynamic>{},
      );

      final districtData = (stateData['districts'] as List?)?.firstWhere(
            (d) => d['district'] == district,
        orElse: () => <String, dynamic>{},
      ) ?? <String, dynamic>{};

      if (districtData.isNotEmpty) {
        final subs = districtData['subDistricts'] as List;
        final seen = <String>{};
        talukasList.value = subs
            .map((s) => s['subDistrict'] as String)
            .where((t) => seen.add(t))
            .toList()
          ..sort();

        // Add district to talukas list if not present
        if (!talukasList.contains(district)) {
          talukasList.insert(0, district);
        }

        debugPrint('✅ Loaded ${talukasList.length} talukas');
      }
    } finally {
      isLoadingTalukas.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LOAD VILLAGES
  // ─────────────────────────────────────────────────────────────
  Future<void> loadVillages(
      String state,
      String district,
      String taluka,
      {bool clearSelection = true}
      ) async {
    isLoadingVillages.value = true;

    villagesList.clear();

    if (clearSelection) {
      selectedVillage.value = null;
    }

    try {
      final stateData = _locationsData.firstWhere(
            (e) => e['state'] == state,
        orElse: () => <String, dynamic>{},
      );

      final districtData = (stateData['districts'] as List?)?.firstWhere(
            (d) => d['district'] == district,
        orElse: () => <String, dynamic>{},
      ) ?? <String, dynamic>{};

      final subData = (districtData['subDistricts'] as List?)?.firstWhere(
            (s) => s['subDistrict'] == taluka,
        orElse: () => <String, dynamic>{},
      ) ?? <String, dynamic>{};

      if (subData.isNotEmpty) {
        final villages = subData['villages'] as List;
        final seen = <String>{};
        villagesList.value = villages
            .map((v) => v.toString())
            .where((v) => seen.add(v))
            .toList()
          ..sort();

        // Add taluka if not in list
        if (!villagesList.contains(taluka)) {
          villagesList.insert(0, taluka);
        }

        // Add district if not in list
        if (!villagesList.contains(district)) {
          villagesList.insert(villagesList.isEmpty ? 0 : 1, district);
        }

        debugPrint('✅ Loaded ${villagesList.length} villages');
      }
    } finally {
      isLoadingVillages.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // STATE SELECTION
  // ─────────────────────────────────────────────────────────────
  Future<void> selectState(String state) async {
    selectedState.value = state;
    await loadDistricts(state, clearSelection: true);
    debugPrint('📍 State selected: $state');
  }

  // ─────────────────────────────────────────────────────────────
  // DISTRICT SELECTION
  // ─────────────────────────────────────────────────────────────
  Future<void> selectDistrict(String district) async {
    selectedDistrict.value = district;
    if (selectedState.value != null) {
      await loadTalukas(selectedState.value!, district, clearSelection: true);
      debugPrint('📍 District selected: $district');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // TALUKA SELECTION
  // ─────────────────────────────────────────────────────────────
  Future<void> selectTaluka(String taluka) async {
    selectedTaluka.value = taluka;
    if (selectedState.value != null && selectedDistrict.value != null) {
      await loadVillages(
        selectedState.value!,
        selectedDistrict.value!,
        taluka,
        clearSelection: true,
      );
      debugPrint('📍 Taluka selected: $taluka');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // VILLAGE SELECTION
  // ─────────────────────────────────────────────────────────────
  void selectVillage(String village) {
    selectedVillage.value = village;
    debugPrint('📍 Village selected: $village');
  }

  // ─────────────────────────────────────────────────────────────
  // SAVE TO SHARED PREFERENCES
  // ─────────────────────────────────────────────────────────────
  Future<void> saveUserLocation() async {
    final prefs = await SharedPreferences.getInstance();

    if (selectedState.value != null && selectedState.value!.isNotEmpty) {
      await prefs.setString('user_state', selectedState.value!);
    } else {
      await prefs.remove('user_state');
    }

    if (selectedDistrict.value != null && selectedDistrict.value!.isNotEmpty) {
      await prefs.setString('user_district', selectedDistrict.value!);
    } else {
      await prefs.remove('user_district');
    }

    if (selectedTaluka.value != null && selectedTaluka.value!.isNotEmpty) {
      await prefs.setString('user_taluka', selectedTaluka.value!);
    } else {
      await prefs.remove('user_taluka');
    }

    if (selectedVillage.value != null && selectedVillage.value!.isNotEmpty) {
      await prefs.setString('user_village', selectedVillage.value!);
    } else {
      await prefs.remove('user_village');
    }

    String fullAddress = _buildFullAddress();
    if (fullAddress.isNotEmpty) {
      await prefs.setString('user_full_address', fullAddress);
    } else {
      await prefs.remove('user_full_address');
    }

    // Set refresh flag
    // await prefs.setBool('marketplace_refresh_needed', true);

    debugPrint('✅ User location saved: $fullAddress');
  }

  // ─────────────────────────────────────────────────────────────
  // LOAD USER LOCATION FROM SHARED PREFERENCES
  // ─────────────────────────────────────────────────────────────
  Future<void> loadUserLocation() async {
    final prefs = await SharedPreferences.getInstance();

    String? state = prefs.getString('user_state');
    String? district = prefs.getString('user_district');
    String? taluka = prefs.getString('user_taluka');
    String? village = prefs.getString('user_village');

    if (state != null && state.isNotEmpty) {
      await initializeWithUserLocation(
        state: state,
        district: district,
        taluka: taluka,
        village: village,
      );
      debugPrint('✅ User location loaded from SharedPreferences');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD FULL ADDRESS STRING
  // ─────────────────────────────────────────────────────────────
  String _buildFullAddress() {
    List<String> parts = [];

    if (selectedVillage.value != null && selectedVillage.value!.isNotEmpty) {
      parts.add(selectedVillage.value!);
    }
    if (selectedTaluka.value != null && selectedTaluka.value!.isNotEmpty) {
      parts.add(selectedTaluka.value!);
    }
    if (selectedDistrict.value != null && selectedDistrict.value!.isNotEmpty) {
      parts.add(selectedDistrict.value!);
    }
    if (selectedState.value != null && selectedState.value!.isNotEmpty) {
      parts.add(selectedState.value!);
    }

    return parts.join(', ');
  }

  // ✅ GET FULL ADDRESS (Public method)
  String getFullAddress() => _buildFullAddress();

  // ─────────────────────────────────────────────────────────────
  // GET LOCATION DATA FOR API
  // ─────────────────────────────────────────────────────────────
  Map<String, String?> getLocationData() {
    return {
      'state': selectedState.value,
      'district': selectedDistrict.value,
      'taluka': selectedTaluka.value,
      'village': selectedVillage.value,
    };
  }

  // ─────────────────────────────────────────────────────────────
  // GET LOCATION QUERY PARAMS FOR MARKETPLACE FILTERING
  // ─────────────────────────────────────────────────────────────
  Map<String, String> getLocationQueryParams() {
    Map<String, String> params = {};

    if (selectedState.value != null && selectedState.value!.isNotEmpty) {
      params['state'] = selectedState.value!;
    }
    if (selectedDistrict.value != null && selectedDistrict.value!.isNotEmpty) {
      params['district'] = selectedDistrict.value!;
    }
    if (selectedTaluka.value != null && selectedTaluka.value!.isNotEmpty) {
      params['taluko'] = selectedTaluka.value!; // API uses 'taluko'
    }
    if (selectedVillage.value != null && selectedVillage.value!.isNotEmpty) {
      params['village'] = selectedVillage.value!;
    }

    return params;
  }

  // ─────────────────────────────────────────────────────────────
  // VALIDATION
  // ─────────────────────────────────────────────────────────────
  String? validateLocation({bool isRequired = false}) {
    if (!isRequired && selectedState.value == null) return null;

    if (selectedState.value == null) return 'Please select a state';
    if (selectedDistrict.value == null) return 'Please select a district';
    if (selectedTaluka.value == null) return 'Please select a taluka';
    if (selectedVillage.value == null || selectedVillage.value!.isEmpty) {
      return 'Please select a village';
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // CLEAR USER LOCATION
  // ─────────────────────────────────────────────────────────────
  Future<void> clearUserLocation() async {
    // Clear observable values
    selectedState.value = null;
    selectedDistrict.value = null;
    selectedTaluka.value = null;
    selectedVillage.value = null;
    
    // Clear lists
    districtsList.clear();
    talukasList.clear();
    villagesList.clear();
    
    // Clear from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_state');
    await prefs.remove('user_district');
    await prefs.remove('user_taluka');
    await prefs.remove('user_village');
    await prefs.remove('user_full_address');
    
    debugPrint('✅ User location cleared from storage and memory');
  }

  // ─────────────────────────────────────────────────────────────
  // RESET
  // ─────────────────────────────────────────────────────────────
  void reset() {
    selectedState.value = null;
    selectedDistrict.value = null;
    selectedTaluka.value = null;
    selectedVillage.value = null;
    districtsList.clear();
    talukasList.clear();
    villagesList.clear();
    debugPrint('🔄 Location controller reset');
  }
}
