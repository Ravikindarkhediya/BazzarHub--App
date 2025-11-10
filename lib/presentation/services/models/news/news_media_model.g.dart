// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsMediaModel _$NewsMediaModelFromJson(Map<String, dynamic> json) =>
    NewsMediaModel(
      type: json['type'] as String? ?? '',
      url: json['url'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      id: json['_id'] as String? ?? '',
    );

Map<String, dynamic> _$NewsMediaModelToJson(NewsMediaModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'url': instance.url,
      'thumbnail': instance.thumbnail,
      '_id': instance.id,
    };
