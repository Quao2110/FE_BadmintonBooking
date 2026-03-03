import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class FetchNotificationsEvent extends NotificationEvent {
  final String userId;
  const FetchNotificationsEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

class MarkNotificationAsReadEvent extends NotificationEvent {
  final String id;
  const MarkNotificationAsReadEvent(this.id);
  @override
  List<Object?> get props => [id];
}
