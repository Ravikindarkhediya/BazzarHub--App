// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsModel _$NewsModelFromJson(Map<String, dynamic> json) => NewsModel(
  title: json['title'] == null
      ? null
      : MultiLangTextModel.fromJson(json['title'] as Map<String, dynamic>),
  content: json['content'] == null
      ? null
      : MultiLangTextModel.fromJson(json['content'] as Map<String, dynamic>),
  location: json['location'] == null
      ? null
      : LocationModel.fromJson(json['location'] as Map<String, dynamic>),
  id: json['_id'] as String? ?? '',
  media:
      (json['media'] as List<dynamic>?)
          ?.map((e) => NewsMediaModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  category: json['category'] == null
      ? null
      : CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  createdBy: json['createdBy'] == null
      ? null
      : UserModel.fromJson(json['createdBy'] as Map<String, dynamic>),
  views: (json['views'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? false,
  createdAt: json['createdAt'] as String? ?? '',
  updatedAt: json['updatedAt'] as String? ?? '',
  relatedNews:
      (json['relatedNews'] as List<dynamic>?)
          ?.map((e) => NewsModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  isFavorite: json['isFavorite'] as bool? ?? false,
);

Map<String, dynamic> _$NewsModelToJson(NewsModel instance) => <String, dynamic>{
  'title': instance.title,
  'content': instance.content,
  'location': instance.location,
  '_id': instance.id,
  'media': instance.media,
  'category': instance.category,
  'tags': instance.tags,
  'createdBy': instance.createdBy,
  'views': instance.views,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'relatedNews': instance.relatedNews,
  'isFavorite': instance.isFavorite,
};
