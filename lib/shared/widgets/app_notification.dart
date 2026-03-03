import '../../../core/services/notification_service.dart';

/// Utility class dùng chung toàn app để hiện push notification trên thanh trạng thái.
///
/// Cách dùng:
/// ```dart
/// AppNotification.showSuccess('Đặt sân thành công!');
/// AppNotification.showError('Đăng nhập thất bại');
/// AppNotification.showWarning('Phiên sắp hết hạn');
/// AppNotification.showInfo('Booking đang được xử lý');
/// ```
class AppNotification {
  AppNotification._();

  static int _nextId = 0;
  static int get _id => _nextId++;

  static Future<void> showSuccess(String body, {String title = 'Thành công ✅'}) =>
      NotificationService.instance.show(
        id: _id,
        title: title,
        body: body,
        type: NotificationType.success,
      );

  static Future<void> showError(String body, {String title = 'Lỗi ❌'}) =>
      NotificationService.instance.show(
        id: _id,
        title: title,
        body: body,
        type: NotificationType.error,
      );

  static Future<void> showWarning(String body, {String title = 'Cảnh báo ⚠️'}) =>
      NotificationService.instance.show(
        id: _id,
        title: title,
        body: body,
        type: NotificationType.warning,
      );

  static Future<void> showInfo(String body, {String title = 'Thông báo ℹ️'}) =>
      NotificationService.instance.show(
        id: _id,
        title: title,
        body: body,
        type: NotificationType.info,
      );
}
