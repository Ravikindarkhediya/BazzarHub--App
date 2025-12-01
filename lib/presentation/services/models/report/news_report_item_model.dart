import 'package:json_annotation/json_annotation.dart';
import '../Common/multi_lang_text_model.dart';

part 'news_report_item_model.g.dart';

@JsonSerializable()
class NewsReportItemModel {
  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  @JsonKey(name: 'title', defaultValue: '')
  final String title;

  @JsonKey(name: 'category', fromJson: NewsReportItemModel._categoryFromJson)
  final MultiLangTextModel? category;

  @JsonKey(name: 'createdBy', defaultValue: '')
  final String createdBy;

  const NewsReportItemModel({
    this.id = '',
    this.title = '',
    this.category,
    this.createdBy = '',
  });

  factory NewsReportItemModel.fromJson(Map<String, dynamic> json) =>
      _$NewsReportItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$NewsReportItemModelToJson(this);

  static MultiLangTextModel? _categoryFromJson(dynamic json) {
    if (json == null || json == '') {
      return null;
    }
    if (json is Map<String, dynamic>) {
      return MultiLangTextModel.fromJson(json);
    }
    return null;
  }
}

