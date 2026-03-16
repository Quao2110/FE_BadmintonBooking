import '../datasources/inbox_api_service.dart';
import '../models/inbox/inbox_models.dart';
import '../../domain/entities/inbox_entity.dart';
import '../../domain/repositories/i_inbox_repository.dart';

class InboxRepository implements IInboxRepository {
  final InboxRemoteDataSource _dataSource;
  InboxRepository({InboxRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? InboxRemoteDataSource();

  @override
  Future<List<ChatRoomEntity>> getAdminChatRooms() async {
    final models = await _dataSource.getAdminChatRooms();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> adminReply({
    required String chatRoomId,
    required String messageText,
    String? imageUrl,
  }) async {
    await _dataSource.adminReply(ReplyMessageRequest(
      chatRoomId: chatRoomId,
      messageText: messageText,
      imageUrl: imageUrl,
    ));
  }

  @override
  Future<void> sendMessage({required String messageText, String? imageUrl}) async {
    await _dataSource.sendMessage(
        SendMessageRequest(messageText: messageText, imageUrl: imageUrl));
  }

  @override
  Future<List<InboxMessageEntity>> getMyMessages() async {
    final models = await _dataSource.getMyMessages();
    return models.map((m) => m.toEntity()).toList();
  }
}
