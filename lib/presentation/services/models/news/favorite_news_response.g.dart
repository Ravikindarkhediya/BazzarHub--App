// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_news_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavoriteNewsResponse _$FavoriteNewsResponseFromJson(
  Map<String, dynamic> json,
) => FavoriteNewsResponse(
  favorites: (json['favorites'] as List<dynamic>)
      .map((e) => NewsModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FavoriteNewsResponseToJson(
  FavoriteNewsResponse instance,
) => <String, dynamic>{'favorites': instance.favorites};
