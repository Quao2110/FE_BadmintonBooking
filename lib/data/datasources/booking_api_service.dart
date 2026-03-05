import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_response.dart';
import '../../core/network/dio_client.dart';
import '../models/booking/booking_availability_model.dart';
import '../models/booking/booking_response_model.dart';
import '../models/booking/booking_create_request.dart';

class BookingRemoteDataSource {
  final Dio dio;
  BookingRemoteDataSource({Dio? dio}) : dio = dio ?? DioClient.instance;

  /// Lấy danh sách slot có sẵn cho một sân vào ngày cụ thể
  Future<ApiResponse<BookingAvailabilityModel>> getAvailability(String courtId, DateTime date) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final res = await dio.get(
        ApiConstants.bookingAvailability,
        queryParameters: {
          'courtId': courtId,
          'date': dateStr,
        },
      );
      return ApiResponse.fromJson(
        res.data,
        (json) => BookingAvailabilityModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Tạo booking mới
  Future<ApiResponse<BookingResponseModel>> createBooking(BookingCreateRequest request) async {
    try {
      final res = await dio.post(
        ApiConstants.bookings,
        data: request.toJson(),
      );
      return ApiResponse.fromJson(
        res.data,
        (json) => BookingResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Lấy lịch sử booking của user
  Future<ApiResponse<List<BookingResponseModel>>> getMyHistory({
    int page = 1,
    int pageSize = 10,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };
      if (status != null) params['status'] = status;
      if (fromDate != null) params['fromDate'] = fromDate.toIso8601String();
      if (toDate != null) params['toDate'] = toDate.toIso8601String();

      final res = await dio.get(ApiConstants.bookingMyHistory, queryParameters: params);
      return ApiResponse.fromJson(
        res.data,
        (json) {
          // API trả về PagedResult: { items: [...], page, pageSize, totalItems, totalPages }
          final pagedResult = json as Map<String, dynamic>;
          final items = pagedResult['items'] as List? ?? [];
          return items
              .map((e) => BookingResponseModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Hủy booking của user
  Future<ApiResponse<BookingResponseModel>> cancelBooking(String bookingId) async {
    try {
      final res = await dio.patch(ApiConstants.bookingCancel(bookingId));
      return ApiResponse.fromJson(
        res.data,
        (json) => BookingResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
