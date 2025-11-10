// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_contact_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketplaceContactInfoModel _$MarketplaceContactInfoModelFromJson(
  Map<String, dynamic> json,
) => MarketplaceContactInfoModel(
  phone:
      (json['phone'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  email:
      (json['email'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
);

Map<String, dynamic> _$MarketplaceContactInfoModelToJson(
  MarketplaceContactInfoModel instance,
) => <String, dynamic>{'phone': instance.phone, 'email': instance.email};
