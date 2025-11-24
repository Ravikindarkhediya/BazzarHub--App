import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: 'name', defaultValue: '')
  String name;

  @JsonKey(name: 'email', defaultValue: '')
  String email;

  @JsonKey(name: 'password', defaultValue: '')
  String password;

  @JsonKey(name: 'avatar', defaultValue: '')
  String avatar;

  @JsonKey(name: 'phone', defaultValue: '')
  String phone;

  @JsonKey(name: 'gender', defaultValue: '')
  String gender;

  @JsonKey(name: 'dob')
  String? dob;

  @JsonKey(name: 'location', defaultValue: '')
  String location;

  @JsonKey(name: 'bio', defaultValue: '')
  String bio;

  @JsonKey(name: 'provider', defaultValue: '')
  String provider;

  @JsonKey(name: 'social_id')
  String? socialId;

  @JsonKey(name: 'social_type', defaultValue: '')
  String socialType;

  @JsonKey(name: '_id', defaultValue: '')
  String id;

  @JsonKey(name: 'district', defaultValue: '')
  String district;

  @JsonKey(name: 'state', defaultValue: '')
  String state;

  @JsonKey(name: 'taluka', defaultValue: '')
  String taluka;

  @JsonKey(name: 'village', defaultValue: '')
  String village;

  @JsonKey(name: 'createdAt', defaultValue: '')
  String createdAt;

  @JsonKey(name: 'updatedAt', defaultValue: '')
  String updatedAt;

  @JsonKey(name: '__v', defaultValue: 0)
  int version;

  UserModel({
    this.name = '',
    this.email = '',
    this.password = '',
    this.avatar = '',
    this.phone = '',
    this.gender = '',
    this.dob = '',
    this.location = '',
    this.bio = '',
    this.provider = '',
    this.socialId = '',
    this.socialType = '',
    this.id = '',
    this.district = '',
    this.state = '',
    this.taluka = '',
    this.village = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.version = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}