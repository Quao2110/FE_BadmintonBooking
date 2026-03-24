import 'package:equatable/equatable.dart';

abstract class InboxEvent extends Equatable {
  const InboxEvent();
  @override
  List<Object?> get props => [];
}

/// Admin: tải danh sách phòng chat
class LoadAdminChatRoomsEvent extends InboxEvent {}

/// Admin: reply khách
class AdminReplyEvent extends InboxEvent {
  final String chatRoomId;
  final String messageText;
  final String? imageUrl;
  const AdminReplyEvent({
    required this.chatRoomId,
    required this.messageText,
    this.imageUrl,
  });
  @override
  List<Object?> get props => [chatRoomId, messageText, imageUrl];
}

/// User: gửi tin nhắn
class SendMessageEvent extends InboxEvent {
  final String messageText;
  final String? imageUrl;
  const SendMessageEvent({required this.messageText, this.imageUrl});
  @override
  List<Object?> get props => [messageText, imageUrl];
}

/// User: tải lịch sử tin nhắn
class LoadMyMessagesEvent extends InboxEvent {}
