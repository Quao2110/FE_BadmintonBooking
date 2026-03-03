import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_response.dart';
import '../../core/network/dio_client.dart';
import '../models/user/notification_model.dart';

class NotificationRemoteDataSource {
  final Dio dio;
  NotificationRemoteDataSource({Dio? dio}) : dio = dio ?? DioClient.instance;

  Future<ApiResponse<List<NotificationModel>>> getNotifications() async {
    try {
      final res = await dio.get(ApiConstants.notifications);
      return ApiResponse.fromJson(
        res.data, 
        (json) => (json as List).map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList()
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<void>> markAsRead(String id) async {
    try {
      final res = await dio.post(ApiConstants.notificationMarkAsRead(id));
      return ApiResponse.fromJson(res.data, (json) => null);
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
