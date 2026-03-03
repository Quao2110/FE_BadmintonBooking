import 'dart:io';
import 'package:flutter/foundation.dart';

/// API URLs and endpoints
class ApiConstants {
  ApiConstants._();

  // Base URL
  // Android Emulator: 10.0.2.2 maps to host localhost
  // Windows/macOS/Linux/Web/iOS Simulator: use localhost
  static String get baseUrl {
    const env = String.fromEnvironment('API_BASE_URL');
    if (env.isNotEmpty) return env;
    const envScheme = String.fromEnvironment('API_SCHEME');
    final scheme = envScheme.isNotEmpty ? envScheme : 'https';
    final port = scheme == 'https' ? 7133 : 5000;
    if (!kIsWeb && Platform.isAndroid) {
      return '$scheme://10.0.2.2:$port';
    }
    return '$scheme://localhost:$port';
  }

  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String verify2faLogin = '/api/auth/login/2fa/verify';
  static const String registerInitiate = '/api/auth/register/initiate';
  static const String registerVerify = '/api/auth/register/verify';
  static const String googleLogin = '/api/auth/login/google';
  static const String registerDirect = '/api/auth/register/direct';

  // User endpoints
  static const String users = '/api/users';
  static String userById(String id) => '/api/users/$id';
  static String userUploadAvatar(String id) => '/api/users/$id/avatar';
  static String userChangePassword(String id) => '/api/users/$id/password';
  static String userByEmail(String email) => '/api/users/email/$email';

  // Category endpoints
  static const String categories = '/api/categories';
  static String categoryById(String id) => '/api/categories/$id';

  // Product endpoints
  static const String products = '/api/products';
  static String productById(String id) => '/api/products/$id';

  // Service endpoints
  static const String services = '/api/services';
  static String serviceById(String id) => '/api/services/$id';

  // Notification endpoints
  static const String notifications = '/api/Notifications';
  static String notificationsByUserId(String userId) => '/api/Notifications/user/$userId';
  static String notificationMarkAsRead(String id) => '/api/Notifications/mark-as-read/$id';

  static String getFullImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return '';
    if (relativePath.startsWith('http')) return relativePath;
    return '${baseUrl}$relativePath';
  }

  // Timeout (milliseconds)
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
