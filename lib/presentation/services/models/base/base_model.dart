import 'package:json_annotation/json_annotation.dart';

part 'base_model.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class BaseModel<T> {
  @JsonKey(name: 'status', fromJson: _statusFromJson)
  final bool status;

  @JsonKey(name: 'data')
  final T? data;

  @JsonKey(name: 'message')
  final String? message;

  BaseModel({
    required this.status,
    this.data,
    this.message,
  });

  factory BaseModel.fromJson(Map<String, dynamic> json, T Function(dynamic json) fromJsonT) =>
      _$BaseModelFromJson(json, fromJsonT);
  
  Map<String, dynamic> toJson() => _$BaseModelToJson(this, (value) => value);

  static bool _statusFromJson(dynamic json) {
    if (json is bool) return json;
    if (json is Map) {
      return json['success'] == true;
    }
    if (json is String) {
      return json.toLowerCase() == 'true';
    }
    return false;
  }
}