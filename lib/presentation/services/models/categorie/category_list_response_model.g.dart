// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_list_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryListResponseModel _$CategoryListResponseModelFromJson(
  Map<String, dynamic> json,
) => CategoryListResponseModel(
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  pagination: json['pagination'] == null
      ? const PaginationModel()
      : PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CategoryListResponseModelToJson(
  CategoryListResponseModel instance,
) => <String, dynamic>{
  'categories': instance.categories,
  'pagination': instance.pagination,
};
