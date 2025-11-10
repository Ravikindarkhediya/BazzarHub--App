// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketplaceLocationModel _$MarketplaceLocationModelFromJson(
  Map<String, dynamic> json,
) => MarketplaceLocationModel(
  coordinates: json['coordinates'] == null
      ? null
      : MarketplaceCoordinatesModel.fromJson(
          json['coordinates'] as Map<String, dynamic>,
        ),
  village: json['village'] as String? ?? '',
  taluko: json['taluko'] as String? ?? '',
  district: json['district'] as String? ?? '',
  zipCode: json['zipCode'] as String? ?? '',
  country: json['country'] as String? ?? '',
);

Map<String, dynamic> _$MarketplaceLocationModelToJson(
  MarketplaceLocationModel instance,
) => <String, dynamic>{
  'coordinates': instance.coordinates,
  'village': instance.village,
  'taluko': instance.taluko,
  'district': instance.district,
  'zipCode': instance.zipCode,
  'country': instance.country,
};
