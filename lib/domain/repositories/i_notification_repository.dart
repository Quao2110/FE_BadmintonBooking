import '../entities/notification_entity.dart';

abstract class INotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> markAsRead(String id);
}
