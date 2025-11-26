import 'package:json_annotation/json_annotation.dart';

import '../Common/multi_lang_text_model.dart';

part 'report_response_item_model.g.dart';

@JsonSerializable()
class ReportItemModel {
  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  @JsonKey(name: 'title', defaultValue: '')
  final String title;

  @JsonKey(name: 'category')
  final MultiLangTextModel? category;

  @JsonKey(name: 'createdBy', defaultValue: '')
  final String createdBy;

  const ReportItemModel({
    this.id = '',
    this.title = '',
    this.category,
    this.createdBy = '',
  });

  factory ReportItemModel.fromJson(Map<String, dynamic> json) =>
      _$ReportItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReportItemModelToJson(this);
}
