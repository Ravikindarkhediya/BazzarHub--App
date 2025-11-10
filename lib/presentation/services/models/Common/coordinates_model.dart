import 'package:json_annotation/json_annotation.dart';

part 'coordinates_model.g.dart';

@JsonSerializable()
class CoordinatesModel {
  @JsonKey(name: 'latitude', defaultValue: 0.0)
  final double latitude;

  @JsonKey(name: 'longitude', defaultValue: 0.0)
  final double longitude;

  const CoordinatesModel({
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  factory CoordinatesModel.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesModelFromJson(json);

  Map<String, dynamic> toJson() => _$CoordinatesModelToJson(this);
}
