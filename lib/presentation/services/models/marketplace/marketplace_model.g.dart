// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketplaceModel _$MarketplaceModelFromJson(Map<String, dynamic> json) =>
    MarketplaceModel(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      category: json['category'] == null
          ? null
          : CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      condition: json['condition'] as String? ?? '',
      type: json['type'] as String? ?? '',
      views: (json['views'] as num?)?.toInt() ?? 0,
      favoritesCount: (json['favoritesCount'] as num?)?.toInt() ?? 0,
      favorites: (json['favorites'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? false,
      location: json['location'] == null
          ? null
          : LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      contactInfo: json['contactInfo'] == null
          ? null
          : MarketplaceContactInfoModel.fromJson(
              json['contactInfo'] as Map<String, dynamic>,
            ),
      createdBy: json['createdBy'] == null
          ? null
          : UserModel.fromJson(json['createdBy'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      version: (json['__v'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$MarketplaceModelToJson(MarketplaceModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'category': instance.category,
      'images': instance.images,
      'condition': instance.condition,
      'type': instance.type,
      'views': instance.views,
      'favoritesCount': instance.favoritesCount,
      'favorites': instance.favorites,
      'isActive': instance.isActive,
      'location': instance.location,
      'contactInfo': instance.contactInfo,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      '__v': instance.version,
    };
