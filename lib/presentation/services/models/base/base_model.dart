import 'package:json_annotation/json_annotation.dart';

part 'base_model.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class BaseModel<T> {
  @JsonKey(name: 'status')
  bool status;

  @JsonKey(name: 'data')
  T? data;

  @JsonKey(name: 'message')
  String? message;

  BaseModel({
    required this.status,
    this.data,
    required this.message,
  });

  factory BaseModel.fromJson(Map<String, dynamic> map, T Function(dynamic json) param1) => _$BaseModelFromJson(map, param1);
  Map<String, dynamic> toJson() => _$BaseModelToJson(this, (value) => value);
}