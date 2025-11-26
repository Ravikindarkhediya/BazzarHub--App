import 'package:bazzar_hub_app/presentation/services/models/categorie/categorie_model.dart';
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

  @JsonKey(name: 'category')
  final CategoryModel? category;

  @JsonKey(name: 'tags', defaultValue: <String>[])
  final List<String> tags;

  @JsonKey(name: 'createdBy')
  final UserModel? createdBy;

  @JsonKey(name: 'views', defaultValue: 0)
  final int views;

  @JsonKey(name: 'isActive', defaultValue: false)
  final bool isActive;

  @JsonKey(name: 'createdAt', defaultValue: '')
  final String createdAt;

  @JsonKey(name: 'updatedAt', defaultValue: '')
  final String updatedAt;

  @JsonKey(name: 'relatedNews', defaultValue: <RelatedNewsModel>[])
  final List<RelatedNewsModel> relatedNews;

  @JsonKey(name: 'isFavorite', defaultValue: false)
  final bool isFavorite;

  const NewsModel({
    this.title,
    this.content,
    this.location,
    this.id = '',
    this.media = const [],
    this.category,
    this.tags = const [],
    this.createdBy,
    this.views = 0,
    this.isActive = false,
    this.createdAt = '',
    this.updatedAt = '',
    this.relatedNews = const [],
    this.isFavorite = false,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) =>
      _$NewsModelFromJson(json);

  Map<String, dynamic> toJson() => _$NewsModelToJson(this);

  NewsModel copyWith({
    MultiLangTextModel? title,
    MultiLangTextModel? content,
    LocationModel? location,
    String? id,
    List<NewsMediaModel>? media,
    CategoryModel? category,
    List<String>? tags,
    UserModel? createdBy,
    int? views,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    List<RelatedNewsModel>? relatedNews,
    bool? isFavorite,
  }) {
    return NewsModel(
      title: title ?? this.title,
      content: content ?? this.content,
      location: location ?? this.location,
      id: id ?? this.id,
      media: media ?? this.media,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdBy: createdBy ?? this.createdBy,
      views: views ?? this.views,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      relatedNews: relatedNews ?? this.relatedNews,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

@JsonSerializable()
class RelatedNewsModel {
  @JsonKey(name: '_id')
  final String id;

  @JsonKey(name: 'title')
  final MultiLangTextModel? title;

  @JsonKey(name: 'content')
  final MultiLangTextModel? content;

  @JsonKey(name: 'media', defaultValue: <NewsMediaModel>[])
  final List<NewsMediaModel> media;

  @JsonKey(name: 'category')
  final CategoryModel? category;

  @JsonKey(name: 'tags', defaultValue: <String>[])
  final List<String> tags;

  @JsonKey(name: 'location')
  final LocationModel? location;

  @JsonKey(name: 'createdBy')
  final UserModel? createdBy;

  @JsonKey(name: 'views', defaultValue: 0)
  final int views;

  @JsonKey(name: 'isActive', defaultValue: false)
  final bool isActive;

  @JsonKey(name: 'createdAt', defaultValue: '')
  final String createdAt;

  @JsonKey(name: 'updatedAt', defaultValue: '')
  final String updatedAt;

  const RelatedNewsModel({
    required this.id,
    this.title,
    this.content,
    this.media = const [],
    this.category,
    this.tags = const [],
    this.location,
    this.createdBy,
    this.views = 0,
    this.isActive = false,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory RelatedNewsModel.fromJson(Map<String, dynamic> json) =>
      _$RelatedNewsModelFromJson(json);

  Map<String, dynamic> toJson() => _$RelatedNewsModelToJson(this);
}
