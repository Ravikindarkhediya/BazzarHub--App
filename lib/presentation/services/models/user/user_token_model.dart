import 'package:bazzar_hub_app/presentation/services/models/user/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_token_model.g.dart';

@JsonSerializable()
class UserTokenModel {
  @JsonKey(name: 'token', defaultValue: '')
  String token;

  @JsonKey(name: 'user')
  UserModel? user;

  UserTokenModel({
    this.token = '',
    this.user,
  });

  factory UserTokenModel.fromJson(Map<String, dynamic> json) =>
      _$UserTokenModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserTokenModelToJson(this);
}
