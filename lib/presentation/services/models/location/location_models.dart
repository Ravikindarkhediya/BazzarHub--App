import 'package:json_annotation/json_annotation.dart';

part 'location_models.g.dart';

@JsonSerializable()
class LocationData {
  final List<StateData> states;

  LocationData({required this.states});

  factory LocationData.fromJson(List<dynamic> json) {
    return LocationData(
      states: json.map((e) => StateData.fromJson(e)).toList(),
    );
  }

  List<dynamic> toJson() => states.map((e) => e.toJson()).toList();
}

@JsonSerializable()
class StateData {
  final String state;
  final List<DistrictData> districts;

  StateData({
    required this.state,
    required this.districts,
  });

  factory StateData.fromJson(Map<String, dynamic> json) =>
      _$StateDataFromJson(json);

  Map<String, dynamic> toJson() => _$StateDataToJson(this);
}

@JsonSerializable()
class DistrictData {
  final String district;
  final List<SubDistrictData>? subDistricts;

  DistrictData({
    required this.district,
    this.subDistricts,
  });

  bool get hasSubDistricts => subDistricts != null && subDistricts!.isNotEmpty;

  factory DistrictData.fromJson(Map<String, dynamic> json) =>
      _$DistrictDataFromJson(json);

  Map<String, dynamic> toJson() => _$DistrictDataToJson(this);
}

@JsonSerializable()
class SubDistrictData {
  final String subDistrict;
  final List<String> villages;

  SubDistrictData({
    required this.subDistrict,
    required this.villages,
  });

  factory SubDistrictData.fromJson(Map<String, dynamic> json) {
    final rawVillages = (json['villages'] as List<dynamic>? ?? [])
        .whereType<String>()
        .map((v) => v.trim())
        .where((v) => v.isNotEmpty)
        .toList();

    return SubDistrictData(
      subDistrict: (json['subDistrict'] as String?)?.trim() ?? '',
      villages: rawVillages,
    );
  }

  Map<String, dynamic> toJson() => _$SubDistrictDataToJson(this);
}