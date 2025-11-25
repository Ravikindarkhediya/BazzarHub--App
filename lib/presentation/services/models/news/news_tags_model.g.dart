// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_tags_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsTagModel _$NewsTagModelFromJson(Map<String, dynamic> json) => NewsTagModel(
  id: json['_id'] as String?,
  name: json['name'] as String?,
  isActive: json['isActive'] as bool? ?? false,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$NewsTagModelToJson(NewsTagModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
