// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_news_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportNewsResponseModel _$ReportNewsResponseModelFromJson(
  Map<String, dynamic> json,
) => ReportNewsResponseModel(
  status: json['status'] as bool,
  message: json['message'] as String,
  data: ReportData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ReportNewsResponseModelToJson(
  ReportNewsResponseModel instance,
) => <String, dynamic>{
  'status': instance.status,
  'message': instance.message,
  'data': instance.data,
};

ReportData _$ReportDataFromJson(Map<String, dynamic> json) =>
    ReportData(reportId: json['reportId'] as String);

Map<String, dynamic> _$ReportDataToJson(ReportData instance) =>
    <String, dynamic>{'reportId': instance.reportId};
