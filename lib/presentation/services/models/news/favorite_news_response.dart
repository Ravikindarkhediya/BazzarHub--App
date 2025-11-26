import 'package:json_annotation/json_annotation.dart';
import 'package:bazzar_hub_app/presentation/services/models/news/news_model.dart';

part 'favorite_news_response.g.dart';

@JsonSerializable()
class FavoriteNewsResponse {
  @JsonKey(name: 'favorites')
  final List<NewsModel> favorites;

  FavoriteNewsResponse({required this.favorites});

  factory FavoriteNewsResponse.fromJson(Map<String, dynamic> json) => 
      _$FavoriteNewsResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$FavoriteNewsResponseToJson(this);
}
