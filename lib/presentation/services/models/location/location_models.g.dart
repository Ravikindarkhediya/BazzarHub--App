// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationData _$LocationDataFromJson(Map<String, dynamic> json) => LocationData(
  states: (json['states'] as List<dynamic>)
      .map((e) => StateData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LocationDataToJson(LocationData instance) =>
    <String, dynamic>{'states': instance.states};

StateData _$StateDataFromJson(Map<String, dynamic> json) => StateData(
  state: json['state'] as String,
  districts: (json['districts'] as List<dynamic>)
      .map((e) => DistrictData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$StateDataToJson(StateData instance) => <String, dynamic>{
  'state': instance.state,
  'districts': instance.districts,
};

DistrictData _$DistrictDataFromJson(Map<String, dynamic> json) => DistrictData(
  district: json['district'] as String,
  subDistricts: (json['subDistricts'] as List<dynamic>?)
      ?.map((e) => SubDistrictData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DistrictDataToJson(DistrictData instance) =>
    <String, dynamic>{
      'district': instance.district,
      'subDistricts': instance.subDistricts,
    };

SubDistrictData _$SubDistrictDataFromJson(Map<String, dynamic> json) =>
    SubDistrictData(
      subDistrict: json['subDistrict'] as String,
      villages: (json['villages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$SubDistrictDataToJson(SubDistrictData instance) =>
    <String, dynamic>{
      'subDistrict': instance.subDistrict,
      'villages': instance.villages,
    };
