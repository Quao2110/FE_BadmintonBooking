import '../entities/notification_entity.dart';

abstract class INotificationRepository {
  Future<List<NotificationEntity>> getNotifications(String userId);
  Future<void> markAsRead(String id);
  Future<void> createNotification(String userId, String title, String message, String type);
}
