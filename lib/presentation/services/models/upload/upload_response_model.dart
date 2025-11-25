import 'package:json_annotation/json_annotation.dart';

part 'upload_response_model.g.dart';

@JsonSerializable()
class UploadResponseModel {
  @JsonKey(name: 'url', defaultValue: '')
  final String url;

  const UploadResponseModel({
    this.url = '',
  });

  factory UploadResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UploadResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$UploadResponseModelToJson(this);
}



