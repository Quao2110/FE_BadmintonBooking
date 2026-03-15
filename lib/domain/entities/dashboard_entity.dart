/// Entity cho 1 điểm dữ liệu doanh thu (1 ngày/tháng/năm)
class RevenuePointEntity {
  final String label; // Nhãn trục X (ngày/tháng/năm)
  final double revenue; // Doanh thu

  const RevenuePointEntity({required this.label, required this.revenue});
}

/// Entity cho thống kê doanh thu đặt sân
class BookingRevenueEntity {
  final double totalRevenue;
  final int totalBookings;
  final List<RevenuePointEntity> revenuePoints; // cho biểu đồ

  const BookingRevenueEntity({
    required this.totalRevenue,
    required this.totalBookings,
    required this.revenuePoints,
  });
}

/// Entity cho 1 sản phẩm bán chạy
class TopProductEntity {
  final String productId;
  final String productName;
  final String? imageUrl;
  final int totalSold;
  final double totalRevenue;

  const TopProductEntity({
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.totalSold,
    required this.totalRevenue,
  });
}

/// Entity cho thống kê doanh thu bán hàng
class OrderRevenueEntity {
  final double totalRevenue;
  final int totalOrders;
  final List<TopProductEntity> topProducts; // top 5

  const OrderRevenueEntity({
    required this.totalRevenue,
    required this.totalOrders,
    required this.topProducts,
  });
}
