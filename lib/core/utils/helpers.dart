import 'dart:convert';
import 'package:flutter/material.dart';


/// Các hàm tiện ích chung
class AppHelpers {
  AppHelpers._();

  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: duration,
      ),
    );
  }

  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  static void hideLoading(BuildContext context) {
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  }
}

/// Giải mã JWT token để lấy claims (không cần verify signature)
class JwtHelper {
  JwtHelper._();

  /// Trả về userId (claim `nameid`) từ JWT token
  static String? getUserId(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      var payload = parts[1];
      payload = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = json.decode(decoded) as Map<String, dynamic>;
      return map['nameid']?.toString() ??
          map['sub']?.toString() ??
          map['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier']?.toString();
    } catch (_) {
      return null;
    }
  }
}
