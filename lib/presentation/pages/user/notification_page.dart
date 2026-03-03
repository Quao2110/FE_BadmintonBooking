import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/colors.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/notification/notification_event.dart';
import '../../bloc/notification/notification_state.dart';
import '../../../domain/entities/notification_entity.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationBloc.create()..add(FetchNotificationsEvent()),
      child: Scaffold(
        backgroundColor: boneColor,
        appBar: AppBar(
          title: const Text('Thông báo cá nhân'),
          backgroundColor: kombuGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => context.read<NotificationBloc>().add(FetchNotificationsEvent()),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator(color: kombuGreen));
            } else if (state is NotificationError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: tanColor),
                    const SizedBox(height: 16),
                    Text(state.message, style: const TextStyle(color: cafeNoir)),
                    TextButton(
                      onPressed: () => context.read<NotificationBloc>().add(FetchNotificationsEvent()),
                      child: const Text('Thử lại', style: TextStyle(color: mossGreen)),
                    ),
                  ],
                ),
              );
            } else if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return const Center(
                  child: Text('Bạn chưa có thông báo nào.', style: TextStyle(color: cafeNoir)),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.notifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = state.notifications[index];
                  return _NotificationItem(
                    notification: item,
                    onTap: () {
                      if (!item.isRead) {
                        context.read<NotificationBloc>().add(MarkNotificationAsReadEvent(item.id));
                      }
                    },
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;
    
    return Container(
      decoration: BoxDecoration(
        color: isRead ? Colors.white.withValues(alpha: 0.6) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? Colors.transparent : kombuGreen.withValues(alpha: 0.1),
        ),
        boxShadow: isRead ? [] : [
          BoxShadow(
            color: kombuGreen.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isRead ? mossGreen : kombuGreen).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIconForType(notification.type),
            color: isRead ? mossGreen : kombuGreen,
            size: 24,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
            color: isRead ? cafeNoir.withValues(alpha: 0.7) : cafeNoir,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                color: cafeNoir.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTime(notification.createdAt),
              style: TextStyle(
                color: cafeNoir.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: isRead ? null : Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: tanColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'booking': return Icons.sports_tennis;
      case 'promotion': return Icons.local_offer_outlined;
      case 'account': return Icons.person_outline;
      case 'system': return Icons.settings_outlined;
      default: return Icons.notifications_none_rounded;
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${time.day}/${time.month}/${time.year}';
  }
}
