// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_response_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportItemModel _$ReportItemModelFromJson(Map<String, dynamic> json) =>
    ReportItemModel(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] == null
          ? null
          : MultiLangTextModel.fromJson(
              json['category'] as Map<String, dynamic>,
            ),
      createdBy: json['createdBy'] as String? ?? '',
    );

Map<String, dynamic> _$ReportItemModelToJson(ReportItemModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'category': instance.category,
      'createdBy': instance.createdBy,
    };
