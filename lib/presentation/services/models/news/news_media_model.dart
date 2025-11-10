import 'package:json_annotation/json_annotation.dart';

part 'news_media_model.g.dart';

@JsonSerializable()
class NewsMediaModel {
  @JsonKey(defaultValue: '')
  final String type;

  @JsonKey(defaultValue: '')
  final String url;

  @JsonKey(defaultValue: '')
  final String thumbnail;

  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  const NewsMediaModel({
    this.type = '',
    this.url = '',
    this.thumbnail = '',
    this.id = '',
  });

  factory NewsMediaModel.fromJson(Map<String, dynamic> json) =>
      _$NewsMediaModelFromJson(json);

  Map<String, dynamic> toJson() => _$NewsMediaModelToJson(this);
}
