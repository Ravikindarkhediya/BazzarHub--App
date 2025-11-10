// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_lang_text_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiLangTextModel _$MultiLangTextModelFromJson(Map<String, dynamic> json) =>
    MultiLangTextModel(
      english: json['english'] as String? ?? '',
      hindi: json['hindi'] as String? ?? '',
      gujarati: json['gujarati'] as String? ?? '',
    );

Map<String, dynamic> _$MultiLangTextModelToJson(MultiLangTextModel instance) =>
    <String, dynamic>{
      'english': instance.english,
      'hindi': instance.hindi,
      'gujarati': instance.gujarati,
    };
