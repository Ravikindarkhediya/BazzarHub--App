import 'package:json_annotation/json_annotation.dart';
import '../Common/multi_lang_text_model.dart';


part 'categorie_model.g.dart';

@JsonSerializable()
class CategoryModel {
  @JsonKey(name: '_id')
  final String? id;

  @JsonKey(name: 'name')
  final MultiLangTextModel? name;

  @JsonKey(name: 'description')
  final MultiLangTextModel? description;

  @JsonKey(name: 'parent',defaultValue: '')
  final String? parent;

  @JsonKey(name: 'icon',defaultValue: '')
  final String? icon;

  @JsonKey(name: 'order', defaultValue: 0)
  final int order;

  @JsonKey(name: 'isActive', defaultValue: false)
  final bool isActive;

  @JsonKey(name: 'createdAt',defaultValue: '')
  final String? createdAt;

  @JsonKey(name: 'updatedAt',defaultValue: '')
  final String? updatedAt;

  @JsonKey(name: '__v', defaultValue: 0)
  final int version;

  const CategoryModel({
    this.id = '',
    this.name,
    this.description,
    this.parent = '',
    this.icon= '',
    this.order = 0,
    this.isActive = false,
    this.createdAt= '',
    this.updatedAt= '',
    this.version = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
}
