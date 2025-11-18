import 'package:json_annotation/json_annotation.dart';

part 'base_list_model.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class BaseListModel<T> {
  @JsonKey(name: 'status')
  bool status;

  @JsonKey(name: 'data')
  List<T>? data;

  @JsonKey(name: 'message')
  String? message;

  BaseListModel({
    required this.status,
    required this.data,
    required this.message,
  });

  factory BaseListModel.fromJson(Map<String, dynamic> map, T Function(Object? json) param1) => _$BaseListModelFromJson(map, param1);
  Map<String, dynamic> toJson() => _$BaseListModelToJson(this, T as Object? Function(Object? value));
}