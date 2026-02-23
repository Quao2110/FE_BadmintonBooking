import 'package:flutter/material.dart';

/// SnackBar helper dùng chung
class NotificationService {
  NotificationService._();

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, Colors.green.shade700, Icons.check_circle_outline);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, Colors.red.shade700, Icons.error_outline);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, Colors.blue.shade700, Icons.info_outline);
  }

  static void _show(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Flexible(child: Text(message)),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
