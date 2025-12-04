import 'package:json_annotation/json_annotation.dart';
import 'news_report_item_model.dart';

part 'news_report_response_model.g.dart';

@JsonSerializable()
class NewsReportResponseModel {
  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  @JsonKey(name: 'news')
  final NewsReportItemModel? news;

  @JsonKey(name: 'reportedBy', defaultValue: '')
  final String reportedBy;

  @JsonKey(name: 'reason', defaultValue: '')
  final String reason;

  @JsonKey(name: 'message', defaultValue: '')
  final String message;

  @JsonKey(name: 'status', defaultValue: '')
  final String status;

  @JsonKey(name: 'createdAt', defaultValue: '')
  final String createdAt;

  @JsonKey(name: 'updatedAt', defaultValue: '')
  final String updatedAt;

  const NewsReportResponseModel({
    this.id = '',
    this.news,
    this.reportedBy = '',
    this.reason = '',
    this.message = '',
    this.status = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory NewsReportResponseModel.fromJson(Map<String, dynamic> json) =>
      _$NewsReportResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$NewsReportResponseModelToJson(this);
}



