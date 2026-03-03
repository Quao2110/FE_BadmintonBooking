import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../datasources/notification_api_service.dart';

class NotificationRepository implements INotificationRepository {
  final NotificationRemoteDataSource _dataSource;
  NotificationRepository({NotificationRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? NotificationRemoteDataSource();

  @override
  Future<List<NotificationEntity>> getNotifications(String userId) async {
    final res = await _dataSource.getNotifications(userId);
    if (res.isSuccess && res.result != null) {
      return res.result!;
    }
    throw Exception(res.message);
  }

  @override
  Future<void> markAsRead(String id) async {
    final res = await _dataSource.markAsRead(id);
    if (!res.isSuccess) throw Exception(res.message);
  }

  @override
  Future<void> createNotification(String userId, String title, String message, String type) async {
    final res = await _dataSource.createNotification({
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
    });
    if (!res.isSuccess) throw Exception(res.message);
  }
}
