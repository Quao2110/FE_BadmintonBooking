import '../entities/inbox_entity.dart';

/// "Hợp đồng" định nghĩa các chức năng của Inbox
abstract class IInboxRepository {
  // Admin: lấy danh sách phòng chat (người dùng đã gửi tin)
  Future<List<ChatRoomEntity>> getAdminChatRooms();

  // Admin: reply (trả lời) khách
  Future<void> adminReply({
    required String chatRoomId,
    required String messageText,
    String? imageUrl,
  });

  // User: gửi tin nhắn cho shop
  Future<void> sendMessage({required String messageText, String? imageUrl});

  // User: lấy lịch sử tin nhắn của mình
  Future<List<InboxMessageEntity>> getMyMessages();
}
