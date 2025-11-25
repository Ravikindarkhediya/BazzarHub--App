import 'package:json_annotation/json_annotation.dart';

part 'report_news_response_model.g.dart';

@JsonSerializable()
class ReportNewsResponseModel {
  final bool status;
  final String message;
  final ReportData data;

  ReportNewsResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ReportNewsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ReportNewsResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReportNewsResponseModelToJson(this);
}

@JsonSerializable()
class ReportData {
  final String reportId;

  ReportData({required this.reportId});

  factory ReportData.fromJson(Map<String, dynamic> json) =>
      _$ReportDataFromJson(json);
  Map<String, dynamic> toJson() => _$ReportDataToJson(this);
}
