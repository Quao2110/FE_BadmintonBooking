import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Lưu trữ bảo mật JWT token bằng flutter_secure_storage
class SecureStorage {
  SecureStorage._();
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.keyJwtToken, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.keyJwtToken);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: AppConstants.keyJwtToken);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
