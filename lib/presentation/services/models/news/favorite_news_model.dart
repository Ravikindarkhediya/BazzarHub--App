import 'package:json_annotation/json_annotation.dart';
import 'package:bazzar_hub_app/presentation/services/models/Common/multi_lang_text_model.dart';
import 'package:bazzar_hub_app/presentation/services/models/Common/location_model.dart';
import 'package:bazzar_hub_app/presentation/services/models/news/news_media_model.dart';

part 'favorite_news_model.g.dart';

@JsonSerializable(explicitToJson: true)
class FavoriteNewsModel {
  @JsonKey(name: '_id')
  final String id;

  @JsonKey(name: 'title')
  final MultiLangTextModel? title;

  @JsonKey(name: 'content')
  final MultiLangTextModel? content;

  @JsonKey(name: 'category')
  final String category;

  @JsonKey(name: 'tags')
  final List<String> tags;

  @JsonKey(name: 'media')
  final List<NewsMediaModel> media;

  @JsonKey(name: 'location')
  final LocationModel? location;

  @JsonKey(name: 'createdBy')
  final String createdBy;

  @JsonKey(name: 'views')
  final int views;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  @JsonKey(name: 'updatedAt')
  final String updatedAt;

  FavoriteNewsModel({
    required this.id,
    this.title,
    this.content,
    required this.category,
    this.tags = const [],
    this.media = const [],
    this.location,
    required this.createdBy,
    required this.views,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FavoriteNewsModel.fromJson(Map<String, dynamic> json) => 
      _$FavoriteNewsModelFromJson(json);
      
  Map<String, dynamic> toJson() => _$FavoriteNewsModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PaginationModel {
  @JsonKey(name: 'total')
  final int total;
  
  @JsonKey(name: 'page')
  final int page;
  
  @JsonKey(name: 'pages')
  final int pages;

  PaginationModel({
    required this.total,
    required this.page,
    required this.pages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) => 
      _$PaginationModelFromJson(json);
      
  Map<String, dynamic> toJson() => _$PaginationModelToJson(this);
}

@JsonSerializable()
class FavoriteNewsListResponse {
  @JsonKey(name: 'favorites')
  final List<FavoriteNewsModel> favorites;
  
  @JsonKey(name: 'pagination')
  final PaginationModel pagination;

  FavoriteNewsListResponse({
    required this.favorites,
    required this.pagination,
  });

  factory FavoriteNewsListResponse.fromJson(Map<String, dynamic> json) => 
      _$FavoriteNewsListResponseFromJson(json);
      
  Map<String, dynamic> toJson() => _$FavoriteNewsListResponseToJson(this);
}
