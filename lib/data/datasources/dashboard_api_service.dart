import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/dashboard/dashboard_models.dart';

/// DataSource gọi API Dashboard thống kê
class DashboardRemoteDataSource {
  final Dio dio;
  DashboardRemoteDataSource({Dio? dio}) : dio = dio ?? DioClient.instance;

  /// Lấy thống kê doanh thu đặt sân (GET /api/dashboard/bookings/revenue?period=day)
  Future<BookingRevenueModel> getBookingRevenue({String period = 'day'}) async {
    try {
      final res = await dio.get(
        ApiConstants.dashboardBookingRevenue,
        queryParameters: {'period': period},
      );
      final data = res.data;
      // Xử lý linh hoạt nếu API wrap trong result
      final Map<String, dynamic> json = data is Map
          ? (data['result'] as Map<String, dynamic>? ?? data as Map<String, dynamic>)
          : {};
      return BookingRevenueModel.fromJson(json);
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Lấy thống kê doanh thu bán hàng & top sản phẩm (GET /api/dashboard/orders/revenue)
  Future<OrderRevenueModel> getOrderRevenue() async {
    try {
      final res = await dio.get(ApiConstants.dashboardOrderRevenue);
      final data = res.data;
      final Map<String, dynamic> json = data is Map
          ? (data['result'] as Map<String, dynamic>? ?? data as Map<String, dynamic>)
          : {};
      return OrderRevenueModel.fromJson(json);
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
