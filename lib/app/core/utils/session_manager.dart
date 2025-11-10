import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../presentation/services/models/user/user_model.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  
  factory SessionManager() {
    return _instance;
  }
  
  SessionManager._internal();

  UserModel? userObjectModel;


  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';

  /// Get the authentication token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Save the authentication token
  Future<bool> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyToken, token);
  }

  /// Get the user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  /// Save the user ID
  Future<bool> setUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyUserId, userId);
  }

  /// Get the user email
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  /// Save the user email
  Future<bool> setUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyUserEmail, email);
  }

  /// Clear all session data (logout)
  Future<bool> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final user = await getUser();
      final token = await getToken();

      return user != null &&
          (user.name.isNotEmpty) &&
          (user.email.isNotEmpty) &&
          (token?.isNotEmpty ?? false);
    } catch (e) {
      return false;
    }
  }


  Future<void> saveUserData(UserModel model) async {
    userObjectModel = model;
    final prefs = await SharedPreferences.getInstance();
    String json = jsonEncode(userObjectModel?.toJson());
    await prefs.setString('LoginUserDetail', json);
  }

  Future<UserModel?> getUser() async {
    if (userObjectModel == null) {
      final prefs = await SharedPreferences.getInstance();
      String? json = prefs.getString('LoginUserDetail');
      if (json != null && json.isNotEmpty) {
        userObjectModel = UserModel.fromJson(jsonDecode(json));
      }
    }
    return userObjectModel;
  }

}
