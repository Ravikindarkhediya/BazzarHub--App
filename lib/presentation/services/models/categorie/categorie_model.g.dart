// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categorie_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      id: json['_id'] as String? ?? '',
      name: json['name'] == null
          ? null
          : MultiLangTextModel.fromJson(json['name'] as Map<String, dynamic>),
      description: json['description'] == null
          ? null
          : MultiLangTextModel.fromJson(
              json['description'] as Map<String, dynamic>,
            ),
      parent: json['parent'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      version: (json['__v'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'parent': instance.parent,
      'icon': instance.icon,
      'order': instance.order,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      '__v': instance.version,
    };
