import 'package:bazzar_hub_app/presentation/services/models/report/report_response_item_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_response_model.g.dart';

@JsonSerializable()
class ReportResponseModel {
  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  @JsonKey(name: 'news')
  final ReportItemModel? news;

  @JsonKey(name: 'listing')
  final ReportItemModel? listing;

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

  const ReportResponseModel({
    this.id = '',
    this.news,
    this.listing,
    this.reportedBy = '',
    this.reason = '',
    this.message = '',
    this.status = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory ReportResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ReportResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReportResponseModelToJson(this);
}
