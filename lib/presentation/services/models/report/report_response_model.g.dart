// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportResponseModel _$ReportResponseModelFromJson(Map<String, dynamic> json) =>
    ReportResponseModel(
      id: json['_id'] as String? ?? '',
      news: json['news'] == null
          ? null
          : ReportItemModel.fromJson(json['news'] as Map<String, dynamic>),
      listing: json['listing'] == null
          ? null
          : ReportItemModel.fromJson(json['listing'] as Map<String, dynamic>),
      reportedUser: json['reportedUser'] == null
          ? null
          : UserModel.fromJson(json['reportedUser'] as Map<String, dynamic>),
      reportedBy: json['reportedBy'],
      reason: json['reason'] as String? ?? '',
      message: json['message'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$ReportResponseModelToJson(
  ReportResponseModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'news': instance.news,
  'listing': instance.listing,
  'reportedUser': instance.reportedUser,
  'reportedBy': instance.reportedBy,
  'reason': instance.reason,
  'message': instance.message,
  'status': instance.status,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
