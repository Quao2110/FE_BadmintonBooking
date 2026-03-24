import '../../../domain/entities/inbox_entity.dart';

/// Model hứng dữ liệu phòng chat từ API (GET /api/admin/inbox/rooms)
class ChatRoomModel {
  final String chatRoomId;
  final String userId;
  final String? userName;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  const ChatRoomModel({
    required this.chatRoomId,
    required this.userId,
    this.userName,
    this.lastMessage,
    this.lastMessageAt,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        final parsed = DateTime.tryParse(value.toString());
        if (parsed != null) return parsed;
      }
      return null;
    }

    return ChatRoomModel(
      chatRoomId: json['chatRoomId']?.toString() ??
          json['id']?.toString() ??
          '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: parseDate(['lastMessageAt', 'updatedAt']),
    );
  }

  ChatRoomEntity toEntity() => ChatRoomEntity(
        chatRoomId: chatRoomId,
        userId: userId,
        userName: userName,
        lastMessage: lastMessage,
        lastMessageAt: lastMessageAt,
      );
}

/// Model hứng dữ liệu tin nhắn từ API (GET /api/inbox/messages)
class InboxMessageModel {
  final String id;
  final String chatRoomId;
  final String? senderId;
  final String? senderName;
  final String? messageText;
  final String? imageUrl;
  final bool isAdminMessage;
  final DateTime? createdAt;

  const InboxMessageModel({
    required this.id,
    required this.chatRoomId,
    this.senderId,
    this.senderName,
    this.messageText,
    this.imageUrl,
    required this.isAdminMessage,
    this.createdAt,
  });

  factory InboxMessageModel.fromJson(Map<String, dynamic> json) {
    return InboxMessageModel(
      id: json['id']?.toString() ?? '',
      chatRoomId: json['chatRoomId']?.toString() ?? '',
      senderId: json['senderId']?.toString(),
      senderName: json['senderName'] as String?,
      messageText: json['messageText'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isAdminMessage: json['isAdminMessage'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  InboxMessageEntity toEntity() => InboxMessageEntity(
        id: id,
        chatRoomId: chatRoomId,
        senderId: senderId,
        senderName: senderName,
        messageText: messageText,
        imageUrl: imageUrl,
        isAdminMessage: isAdminMessage,
        createdAt: createdAt,
      );
}

/// Request gửi tin nhắn của user (POST /api/inbox/messages)
class SendMessageRequest {
  final String? messageText;
  final String? imageUrl;

  const SendMessageRequest({this.messageText, this.imageUrl});

  Map<String, dynamic> toJson() => {
        if (messageText != null) 'messageText': messageText,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };
}

/// Request admin reply (POST /api/admin/inbox/reply)
class ReplyMessageRequest {
  final String chatRoomId;
  final String? messageText;
  final String? imageUrl;

  const ReplyMessageRequest({
    required this.chatRoomId,
    this.messageText,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'chatRoomId': chatRoomId,
        if (messageText != null) 'messageText': messageText,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };
}
