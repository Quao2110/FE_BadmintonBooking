import 'package:equatable/equatable.dart';
import '../../../domain/entities/inbox_entity.dart';

abstract class InboxState extends Equatable {
  const InboxState();
  @override
  List<Object?> get props => [];
}

class InboxInitial extends InboxState {}

class InboxLoading extends InboxState {}

/// Admin: đã load được danh sách phòng chat
class AdminChatRoomsLoaded extends InboxState {
  final List<ChatRoomEntity> rooms;
  const AdminChatRoomsLoaded(this.rooms);
  @override
  List<Object?> get props => [rooms];
}

/// Đã gửi tin nhắn (user hoặc admin reply) thành công
class InboxMessageSent extends InboxState {}

/// User: đã load được lịch sử tin nhắn của mình
class MyMessagesLoaded extends InboxState {
  final List<InboxMessageEntity> messages;
  const MyMessagesLoaded(this.messages);
  @override
  List<Object?> get props => [messages];
}

class InboxError extends InboxState {
  final String message;
  const InboxError(this.message);
  @override
  List<Object?> get props => [message];
}
