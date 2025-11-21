import 'package:json_annotation/json_annotation.dart';

import 'news_media_model.dart';
import 'package:bazzar_hub_app/presentation/services/models/Common/location_model.dart';
import 'package:bazzar_hub_app/presentation/services/models/Common/multi_lang_text_model.dart';
import 'package:bazzar_hub_app/presentation/services/models/user/user_model.dart';

part 'news_model.g.dart';

@JsonSerializable()
class NewsModel {
  @JsonKey(name: 'title')
  final MultiLangTextModel? title;

  @JsonKey(name: 'content')
  final MultiLangTextModel? content;

  @JsonKey(name: 'location')
  final LocationModel? location;

  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  @JsonKey(name: 'media', defaultValue: <NewsMediaModel>[])
  final List<NewsMediaModel> media;

  @JsonKey(name: 'category', defaultValue: '')
  final String category;

  @JsonKey(name: 'tags', defaultValue: <String>[])
  final List<String> tags;

  @JsonKey(name: 'createdBy')
  final UserModel? createdBy;

  @JsonKey(name: 'views', defaultValue: 0)
  final int views;

  @JsonKey(name: 'isActive', defaultValue: false)
  final bool? isActive;

  @JsonKey(name: 'createdAt', defaultValue: '')
  final String createdAt;

  @JsonKey(name: 'updatedAt', defaultValue: '')
  final String updatedAt;

  const NewsModel({
    this.title,
    this.content,
    this.location,
    this.id = '',
    this.media = const [],
    this.category = '',
    this.tags = const [],
    this.createdBy,
    this.views = 0,
    this.isActive ,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) =>
      _$NewsModelFromJson(json);

  Map<String, dynamic> toJson() => _$NewsModelToJson(this);
}
