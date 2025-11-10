import 'package:json_annotation/json_annotation.dart';

part 'pagination_model.g.dart';

@JsonSerializable()
class PaginationModel {
  @JsonKey(name: 'total', defaultValue: 1)
  final int total;

  @JsonKey(name: 'page', defaultValue: 1)
  final int page;

  @JsonKey(name: 'pages', defaultValue: 1)
  final int pages;

  const PaginationModel({
    this.total = 1,
    this.page = 1,
    this.pages = 1,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) =>
      _$PaginationModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationModelToJson(this);
}
