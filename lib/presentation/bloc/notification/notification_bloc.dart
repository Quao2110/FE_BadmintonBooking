import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/notification_repository_impl.dart';
import '../../../domain/repositories/i_notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final INotificationRepository repository;

  NotificationBloc({required this.repository}) : super(NotificationInitial()) {
    on<FetchNotificationsEvent>(_onFetch);
    on<MarkNotificationAsReadEvent>(_onMarkRead);
  }

  factory NotificationBloc.create() {
    return NotificationBloc(repository: NotificationRepository());
  }

  Future<void> _onFetch(FetchNotificationsEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final notifications = await repository.getNotifications(event.userId);
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onMarkRead(MarkNotificationAsReadEvent event, Emitter<NotificationState> emit) async {
    try {
      await repository.markAsRead(event.id);
      if (state is NotificationLoaded) {
        final userId = (state as NotificationLoaded).notifications.firstWhere((n) => n.id == event.id).userId;
        add(FetchNotificationsEvent(userId));
      }
    } catch (e) {
      // Handle error silently or log it
    }
  }
}
