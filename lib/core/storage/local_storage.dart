import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Lưu trữ thông tin user (không nhạy cảm) bằng SharedPreferences
class LocalStorage {
  LocalStorage._();

  static Future<void> saveUserInfo({
    required String email,
    String? fullName,
    String? role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserEmail, email);
    if (fullName != null) await prefs.setString(AppConstants.keyUserFullName, fullName);
    if (role != null) await prefs.setString(AppConstants.keyUserRole, role);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserEmail);
  }

  static Future<String?> getUserFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserFullName);
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserRole);
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyUserEmail);
    await prefs.remove(AppConstants.keyUserFullName);
    await prefs.remove(AppConstants.keyUserRole);
  }
}
