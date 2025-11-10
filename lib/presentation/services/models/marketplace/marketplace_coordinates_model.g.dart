// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_coordinates_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketplaceCoordinatesModel _$MarketplaceCoordinatesModelFromJson(
  Map<String, dynamic> json,
) => MarketplaceCoordinatesModel(
  latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
  longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$MarketplaceCoordinatesModelToJson(
  MarketplaceCoordinatesModel instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};
