// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  name: json['name'] as String? ?? '',
  email: json['email'] as String? ?? '',
  password: json['password'] as String? ?? '',
  avatar: json['avatar'] as String? ?? '',
  phone: json['phone'] as String? ?? '',
  gender: json['gender'] as String? ?? '',
  dob: json['dob'] as String? ?? '',
  location: json['location'] as String? ?? '',
  bio: json['bio'] as String? ?? '',
  provider: json['provider'] as String? ?? '',
  socialId: json['social_id'] as String? ?? '',
  socialType: json['social_type'] as String? ?? '',
  id: json['_id'] as String? ?? '',
  createdAt: json['createdAt'] as String? ?? '',
  updatedAt: json['updatedAt'] as String? ?? '',
  version: (json['__v'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'name': instance.name,
  'email': instance.email,
  'password': instance.password,
  'avatar': instance.avatar,
  'phone': instance.phone,
  'gender': instance.gender,
  'dob': instance.dob,
  'location': instance.location,
  'bio': instance.bio,
  'provider': instance.provider,
  'social_id': instance.socialId,
  'social_type': instance.socialType,
  '_id': instance.id,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  '__v': instance.version,
};
