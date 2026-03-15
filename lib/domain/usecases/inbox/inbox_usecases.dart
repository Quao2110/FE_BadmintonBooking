import '../../entities/inbox_entity.dart';
import '../../repositories/i_inbox_repository.dart';

class GetAdminChatRoomsUseCase {
  final IInboxRepository repository;
  GetAdminChatRoomsUseCase(this.repository);

  Future<List<ChatRoomEntity>> call() => repository.getAdminChatRooms();
}

class AdminReplyUseCase {
  final IInboxRepository repository;
  AdminReplyUseCase(this.repository);

  Future<void> call({
    required String chatRoomId,
    required String messageText,
    String? imageUrl,
  }) =>
      repository.adminReply(
          chatRoomId: chatRoomId,
          messageText: messageText,
          imageUrl: imageUrl);
}

class SendMessageUseCase {
  final IInboxRepository repository;
  SendMessageUseCase(this.repository);

  Future<void> call({required String messageText, String? imageUrl}) =>
      repository.sendMessage(messageText: messageText, imageUrl: imageUrl);
}

class GetMyMessagesUseCase {
  final IInboxRepository repository;
  GetMyMessagesUseCase(this.repository);

  Future<List<InboxMessageEntity>> call() => repository.getMyMessages();
}
