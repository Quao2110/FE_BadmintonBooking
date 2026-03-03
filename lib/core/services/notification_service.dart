import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service quản lý local notifications trên Android.
/// Khởi tạo một lần ở main.dart, sau đó dùng [NotificationService.instance]
/// hoặc các static method trong [AppNotification].
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Gọi một lần duy nhất trong main() trước runApp()
  Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  /// Xin quyền POST_NOTIFICATIONS (Android 13+)
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Hiển thị notification với title, body và loại tùy chọn
  Future<void> show({
    required int id,
    required String title,
    required String body,
    NotificationType type = NotificationType.info,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      type.channelId,
      type.channelName,
      channelDescription: type.channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: type.color,
      playSound: true,
      enableVibration: true,
    );

    final details = NotificationDetails(android: androidDetails);
    await _plugin.show(id, title, body, details);
  }

  void _onNotificationTap(NotificationResponse response) {
    // TODO: navigate to relevant screen based on response.payload
  }
}

// ---------------------------------------------------------------------------

enum NotificationType {
  success(
    channelId: 'success_channel',
    channelName: 'Thành công',
    channelDesc: 'Thông báo khi thao tác thành công',
    color: Color(0xFF4CAF50),
  ),
  error(
    channelId: 'error_channel',
    channelName: 'Lỗi',
    channelDesc: 'Thông báo khi có lỗi xảy ra',
    color: Color(0xFFF44336),
  ),
  warning(
    channelId: 'warning_channel',
    channelName: 'Cảnh báo',
    channelDesc: 'Thông báo cảnh báo',
    color: Color(0xFFFF9800),
  ),
  info(
    channelId: 'info_channel',
    channelName: 'Thông tin',
    channelDesc: 'Thông báo thông tin chung',
    color: Color(0xFF2196F3),
  );

  const NotificationType({
    required this.channelId,
    required this.channelName,
    required this.channelDesc,
    required this.color,
  });

  final String channelId;
  final String channelName;
  final String channelDesc;
  final Color color;
}
