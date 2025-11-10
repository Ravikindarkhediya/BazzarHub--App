import 'package:json_annotation/json_annotation.dart';
import 'marketplace_coordinates_model.dart';

part 'marketplace_location_model.g.dart';

@JsonSerializable()
class MarketplaceLocationModel {
  @JsonKey(name: 'coordinates')
  final MarketplaceCoordinatesModel? coordinates;

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

  const MarketplaceLocationModel({
    this.coordinates,
    this.village = '',
    this.taluko = '',
    this.district = '',
    this.zipCode = '',
    this.country = '',
  });

  factory MarketplaceLocationModel.fromJson(Map<String, dynamic> json) =>
      _$MarketplaceLocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$MarketplaceLocationModelToJson(this);
}
