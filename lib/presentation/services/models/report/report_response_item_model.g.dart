// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_response_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportItemModel _$ReportItemModelFromJson(Map<String, dynamic> json) =>
    ReportItemModel(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: ReportItemModel._categoryFromJson(json['category']),
      createdBy: json['createdBy'] as String? ?? '',
    );

Map<String, dynamic> _$ReportItemModelToJson(ReportItemModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'category': instance.category,
      'createdBy': instance.createdBy,
    };
