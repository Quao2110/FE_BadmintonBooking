import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/inbox/inbox_models.dart';

/// DataSource gọi API cho Inbox (User & Admin)
class InboxRemoteDataSource {
  final Dio dio;
  InboxRemoteDataSource({Dio? dio}) : dio = dio ?? DioClient.instance;

  // ─── User APIs ───────────────────────────────────────────────────────────

  /// Gửi tin nhắn cho shop (POST /api/inbox/messages)
  Future<void> sendMessage(SendMessageRequest request) async {
    try {
      await dio.post(ApiConstants.inboxMessages, data: request.toJson());
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Lấy lịch sử tin nhắn của user (GET /api/inbox/messages)
  Future<List<InboxMessageModel>> getMyMessages() async {
    try {
      final res = await dio.get(ApiConstants.inboxMessages);
      // Hứng dữ liệu linh hoạt: list, result/items/data/messages
      final rawList = _extractList(res.data);
      return rawList
          .map((e) => InboxMessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // ─── Admin APIs ──────────────────────────────────────────────────────────

  /// Lấy danh sách phòng chat (GET /api/admin/inbox/rooms)
  Future<List<ChatRoomModel>> getAdminChatRooms() async {
    try {
      final res = await dio.get(ApiConstants.adminInboxRooms);
      final rawList = _extractList(res.data);
      return rawList
          .map((e) => ChatRoomModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Admin reply khách (POST /api/admin/inbox/reply)
  Future<void> adminReply(ReplyMessageRequest request) async {
    try {
      await dio.post(ApiConstants.adminInboxReply, data: request.toJson());
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final candidates = [
        map['rooms'],
        map['result'],
        map['items'],
        map['data'],
        map['messages'],
      ];
      for (final c in candidates) {
        if (c is List) return c;
      }
    }
    return const <dynamic>[];
  }

}
