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
      final notifications = await repository.getNotifications();
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onMarkRead(MarkNotificationAsReadEvent event, Emitter<NotificationState> emit) async {
    try {
      await repository.markAsRead(event.id);
      if (state is NotificationLoaded) {
        final currentList = (state as NotificationLoaded).notifications;
        final updatedList = currentList.map((n) {
          if (n.id == event.id) {
            // Since entities are usually immutable, we just return a new one if possible or re-fetch
            // For simplicity in this structure, we could re-fetch or use a copyWith if defined
            return n; // Placeholder
          }
          return n;
        }).toList();
        // Option 1: Re-fetch for accuracy
        add(FetchNotificationsEvent());
      }
    } catch (e) {
      // Handle error silently or log it
    }
  }
}
