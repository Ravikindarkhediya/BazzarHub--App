// // lib/models/auth_models.dart
// import 'package:json_annotation/json_annotation.dart';
//
// part 'auth_models.g.dart';
//
// /// 🌟 Generic API Response
// @JsonSerializable(genericArgumentFactories: true)
// class ApiResponse<T> {
//   final bool status;
//   final String message;
//   final T? data;
//
//   ApiResponse({
//     required this.status,
//     required this.message,
//     this.data,
//   });
//
//   factory ApiResponse.fromJson(
//       Map<String, dynamic> json,
//       T Function(Object? json) fromJsonT,
//       ) =>
//       _$ApiResponseFromJson(json, fromJsonT);
//
//   Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
//       _$ApiResponseToJson(this, toJsonT);
// }
//
// /// 🧍 User Model (same for signup and signin.user)
// @JsonSerializable()
// class UserModel {
//   @JsonKey(name: '_id')
//   final String id;
//   final String name;
//   final String email;
//   final String avatar;
//   final String phone;
//   final String gender;
//   final String? dob;
//   final String location;
//   final String provider;
//   @JsonKey(name: 'social_id')
//   final String? socialId;
//   @JsonKey(name: 'social_type')
//   final String socialType;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//
//   UserModel({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.avatar,
//     required this.phone,
//     required this.gender,
//     this.dob,
//     required this.location,
//     required this.provider,
//     this.socialId,
//     required this.socialType,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory UserModel.fromJson(Map<String, dynamic> json) =>
//       _$UserModelFromJson(json);
//   Map<String, dynamic> toJson() => _$UserModelToJson(this);
// }
//
// /// 🔑 LoginData (contains token + user)
// @JsonSerializable()
// class LoginData {
//   final String token;
//   final UserModel user;
//
//   LoginData({
//     required this.token,
//     required this.user,
//   });
//
//   factory LoginData.fromJson(Map<String, dynamic> json) =>
//       _$LoginDataFromJson(json);
//   Map<String, dynamic> toJson() => _$LoginDataToJson(this);
// }
