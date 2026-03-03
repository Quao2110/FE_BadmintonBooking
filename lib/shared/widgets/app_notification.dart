import '../../../core/services/notification_service.dart';
import '../../../data/repositories/notification_repository_impl.dart';

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

  static final _repository = NotificationRepository();

  static Future<void> showSuccess(String body, {String title = 'Thành công ✅', String? userId}) async {
    await NotificationService.instance.show(
      id: _id,
      title: title,
      body: body,
      type: NotificationType.success,
    );
    if (userId != null) {
      _repository.createNotification(userId, title, body, 'success');
    }
  }

  static Future<void> showError(String body, {String title = 'Lỗi ❌', String? userId}) async {
    await NotificationService.instance.show(
      id: _id,
      title: title,
      body: body,
      type: NotificationType.error,
    );
    if (userId != null) {
      _repository.createNotification(userId, title, body, 'error');
    }
  }

  static Future<void> showWarning(String body, {String title = 'Cảnh báo ⚠️', String? userId}) async {
    await NotificationService.instance.show(
      id: _id,
      title: title,
      body: body,
      type: NotificationType.warning,
    );
    if (userId != null) {
      _repository.createNotification(userId, title, body, 'warning');
    }
  }

  static Future<void> showInfo(String body, {String title = 'Thông báo ℹ️', String? userId}) async {
    await NotificationService.instance.show(
      id: _id,
      title: title,
      body: body,
      type: NotificationType.info,
    );
    if (userId != null) {
      _repository.createNotification(userId, title, body, 'info');
    }
  }
}
