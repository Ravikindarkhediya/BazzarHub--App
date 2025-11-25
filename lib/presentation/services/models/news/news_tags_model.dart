import 'package:json_annotation/json_annotation.dart';

part 'news_tags_model.g.dart';

@JsonSerializable()
class NewsTagModel {
  @JsonKey(name: '_id')
  final String? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'isActive', defaultValue: false)
  final bool isActive;

  @JsonKey(name: 'createdAt')
  final String? createdAt;

  @JsonKey(name: 'updatedAt')
  final String? updatedAt;

  const NewsTagModel({
    this.id,
    this.name,
    this.isActive = false,
    this.createdAt,
    this.updatedAt,
  });

  factory NewsTagModel.fromJson(Map<String, dynamic> json) =>
      _$NewsTagModelFromJson(json);

  Map<String, dynamic> toJson() => _$NewsTagModelToJson(this);
}
