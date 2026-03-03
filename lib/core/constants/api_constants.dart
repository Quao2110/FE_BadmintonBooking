import 'dart:io';
import 'package:flutter/foundation.dart';

/// Tập trung toàn bộ URL và endpoint của API
class ApiConstants {
  ApiConstants._();

  // ── Base URL ──────────────────────────────────────────────────────────
  // Android Emulator: 10.0.2.2 trỏ về localhost của máy host
  // Windows/macOS/Linux/Web/iOS Simulator: dùng localhost
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:5000';   // Android Emulator → HTTP port
    }
    return 'http://localhost:5000';    // Windows / iOS Sim / Web → HTTP port
  }

  // ── Auth endpoints ────────────────────────────────────────────────────
  static const String login = '/api/auth/login';
  static const String verify2faLogin = '/api/auth/login/2fa/verify';
  static const String registerInitiate = '/api/auth/register/initiate';
  static const String registerVerify = '/api/auth/register/verify';
  static const String googleLogin = '/api/auth/login/google';
  static const String registerDirect = '/api/auth/register/direct';

  // ── User endpoints ────────────────────────────────────────────────────
  static const String users = '/api/users';
  static String userById(String id) => '/api/users/$id';
  static String userUploadAvatar(String id) => '/api/users/$id/avatar';
  static String userChangePassword(String id) => '/api/users/$id/password';
  static String userByEmail(String email) => '/api/users/email/$email'; // If needed

  // ── Category endpoints ─────────────────────────────────────────────
  static const String categories = '/api/categories';
  static String categoryById(String id) => '/api/categories/$id';

  // ── Product endpoints ──────────────────────────────────────────────
  static const String products = '/api/products';
  static String productById(String id) => '/api/products/$id';

  // ── Service endpoints ──────────────────────────────────────────────
  static const String services = '/api/services';
  static String serviceById(String id) => '/api/services/$id';

  static String getFullImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return '';
    if (relativePath.startsWith('http')) return relativePath;
    return '${baseUrl}$relativePath';
  }

  // ── Timeout (milliseconds) ────────────────────────────────────────────
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}
