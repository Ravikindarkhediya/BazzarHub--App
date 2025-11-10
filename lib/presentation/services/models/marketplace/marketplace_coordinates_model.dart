import 'package:json_annotation/json_annotation.dart';

part 'marketplace_coordinates_model.g.dart';

@JsonSerializable()
class MarketplaceCoordinatesModel {
  @JsonKey(name: 'latitude', defaultValue: 0.0)
  final double latitude;

  @JsonKey(name: 'longitude', defaultValue: 0.0)
  final double longitude;

  const MarketplaceCoordinatesModel({
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  factory MarketplaceCoordinatesModel.fromJson(Map<String, dynamic> json) =>
      _$MarketplaceCoordinatesModelFromJson(json);

  Map<String, dynamic> toJson() => _$MarketplaceCoordinatesModelToJson(this);
}
