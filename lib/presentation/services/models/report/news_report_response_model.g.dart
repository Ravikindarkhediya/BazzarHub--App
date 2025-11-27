// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_report_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsReportResponseModel _$NewsReportResponseModelFromJson(
  Map<String, dynamic> json,
) => NewsReportResponseModel(
  id: json['_id'] as String? ?? '',
  news: json['news'] == null
      ? null
      : NewsReportItemModel.fromJson(json['news'] as Map<String, dynamic>),
  reportedBy: json['reportedBy'] as String? ?? '',
  reason: json['reason'] as String? ?? '',
  message: json['message'] as String? ?? '',
  status: json['status'] as String? ?? '',
  createdAt: json['createdAt'] as String? ?? '',
  updatedAt: json['updatedAt'] as String? ?? '',
);

Map<String, dynamic> _$NewsReportResponseModelToJson(
  NewsReportResponseModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'news': instance.news,
  'reportedBy': instance.reportedBy,
  'reason': instance.reason,
  'message': instance.message,
  'status': instance.status,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
