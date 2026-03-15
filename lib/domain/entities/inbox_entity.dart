/// Entity đại diện cho một phòng chat (cuộc hội thoại giữa 1 user và admin)
class ChatRoomEntity {
  final String chatRoomId;
  final String userId;
  final String? userName;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  const ChatRoomEntity({
    required this.chatRoomId,
    required this.userId,
    this.userName,
    this.lastMessage,
    this.lastMessageAt,
  });
}

/// Entity đại diện cho một tin nhắn trong hộp thư
class InboxMessageEntity {
  final String id;
  final String chatRoomId;
  final String? senderId;
  final String? senderName;
  final String? messageText;
  final String? imageUrl;
  final bool isAdminMessage;
  final DateTime? createdAt;

  const InboxMessageEntity({
    required this.id,
    required this.chatRoomId,
    this.senderId,
    this.senderName,
    this.messageText,
    this.imageUrl,
    required this.isAdminMessage,
    this.createdAt,
  });
}
