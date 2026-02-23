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
      return 'http://10.0.2.2:5151';   // Android Emulator → HTTP port
    }
    return 'https://localhost:7133';    // Windows / iOS Sim / Web → HTTPS port
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

  static String getFullImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return '';
    if (relativePath.startsWith('http')) return relativePath;
    return '${baseUrl}$relativePath';
  }

  // ── Timeout (milliseconds) ────────────────────────────────────────────
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}
