import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../datasources/notification_api_service.dart';

class NotificationRepository implements INotificationRepository {
  final NotificationRemoteDataSource _dataSource;
  NotificationRepository({NotificationRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? NotificationRemoteDataSource();

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final res = await _dataSource.getNotifications();
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
}
