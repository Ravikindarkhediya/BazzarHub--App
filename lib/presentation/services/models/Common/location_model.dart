import 'package:json_annotation/json_annotation.dart';
import 'coordinates_model.dart';

part 'location_model.g.dart';

@JsonSerializable()
class LocationModel {
  @JsonKey(name: 'coordinates')
  final CoordinatesModel? coordinates;

  @JsonKey(name: 'village', defaultValue: '')
  final String village;

  @JsonKey(name: 'taluko', defaultValue: '')
  final String taluko;

  @JsonKey(name: 'district', defaultValue: '')
  final String district;

  @JsonKey(name: 'zipCode', defaultValue: '')
  final String zipCode;

  @JsonKey(name: 'country', defaultValue: '')
  final String country;

  const LocationModel({
    this.coordinates,
    this.village = '',
    this.taluko = '',
    this.district = '',
    this.zipCode = '',
    this.country = '',
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationModelToJson(this);
}
