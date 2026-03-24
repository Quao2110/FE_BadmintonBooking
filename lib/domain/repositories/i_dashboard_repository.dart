import '../entities/dashboard_entity.dart';

/// "Hợp đồng" định nghĩa các chức năng của Dashboard
abstract class IDashboardRepository {
  /// Lấy thống kê doanh thu đặt sân
  /// [period]: 'day' | 'month' | 'year'
  Future<BookingRevenueEntity> getBookingRevenue({String period = 'day'});

  /// Lấy thống kê doanh thu bán hàng & top sản phẩm
  Future<OrderRevenueEntity> getOrderRevenue();
}
