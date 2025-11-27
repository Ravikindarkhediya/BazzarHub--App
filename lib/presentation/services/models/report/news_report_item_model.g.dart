// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_report_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsReportItemModel _$NewsReportItemModelFromJson(Map<String, dynamic> json) =>
    NewsReportItemModel(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: NewsReportItemModel._categoryFromJson(json['category']),
      createdBy: json['createdBy'] as String? ?? '',
    );

Map<String, dynamic> _$NewsReportItemModelToJson(
  NewsReportItemModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'title': instance.title,
  'category': instance.category,
  'createdBy': instance.createdBy,
};
