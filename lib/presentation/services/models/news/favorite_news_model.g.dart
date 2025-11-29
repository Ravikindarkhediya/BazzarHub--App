// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_news_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavoriteNewsModel _$FavoriteNewsModelFromJson(Map<String, dynamic> json) =>
    FavoriteNewsModel(
      id: json['_id'] as String,
      title: json['title'] as String?,
      content: json['content'] as String?,
      category: json['category'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      media:
          (json['media'] as List<dynamic>?)
              ?.map((e) => NewsMediaModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      location: json['location'] == null
          ? null
          : LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      createdBy: json['createdBy'] as String,
      views: (json['views'] as num).toInt(),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$FavoriteNewsModelToJson(FavoriteNewsModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'category': instance.category,
      'tags': instance.tags,
      'media': instance.media.map((e) => e.toJson()).toList(),
      'location': instance.location?.toJson(),
      'createdBy': instance.createdBy,
      'views': instance.views,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

PaginationModel _$PaginationModelFromJson(Map<String, dynamic> json) =>
    PaginationModel(
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      pages: (json['pages'] as num).toInt(),
    );

Map<String, dynamic> _$PaginationModelToJson(PaginationModel instance) =>
    <String, dynamic>{
      'total': instance.total,
      'page': instance.page,
      'pages': instance.pages,
    };

FavoriteNewsListResponse _$FavoriteNewsListResponseFromJson(
  Map<String, dynamic> json,
) => FavoriteNewsListResponse(
  favorites: (json['favorites'] as List<dynamic>)
      .map((e) => FavoriteNewsModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: PaginationModel.fromJson(
    json['pagination'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$FavoriteNewsListResponseToJson(
  FavoriteNewsListResponse instance,
) => <String, dynamic>{
  'favorites': instance.favorites,
  'pagination': instance.pagination,
};
