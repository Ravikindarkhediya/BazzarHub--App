import 'package:json_annotation/json_annotation.dart';

part 'multi_lang_text_model.g.dart';

@JsonSerializable()
class MultiLangTextModel {
  @JsonKey(name: 'english',defaultValue: '')
  final String? english;

  @JsonKey(name: 'hindi',defaultValue: '')
  final String? hindi;

  @JsonKey(name: 'gujarati',defaultValue: '')
  final String? gujarati;

  const MultiLangTextModel({
    this.english = '',
    this.hindi = '',
    this.gujarati = '',
  });

  factory MultiLangTextModel.fromJson(Map<String, dynamic> json) =>
      _$MultiLangTextModelFromJson(json);

  Map<String, dynamic> toJson() => _$MultiLangTextModelToJson(this);
}
