// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseListModel<T> _$BaseListModelFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => BaseListModel<T>(
  status: json['status'] as bool,
  data: (json['data'] as List<dynamic>?)?.map(fromJsonT).toList(),
  message: json['message'] as String?,
  pagination: json['pagination'] == null
      ? const PaginationModel()
      : PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BaseListModelToJson<T>(
  BaseListModel<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'status': instance.status,
  'data': instance.data?.map(toJsonT).toList(),
  'message': instance.message,
  'pagination': instance.pagination,
};
