import '../../../domain/entities/dashboard_entity.dart';

// ─── Dashboard Booking Revenue ─────────────────────────────────────────────

class RevenuePointModel {
  final String label;
  final double revenue;

  const RevenuePointModel({required this.label, required this.revenue});

  factory RevenuePointModel.fromJson(Map<String, dynamic> json) {
    return RevenuePointModel(
      label: json['label']?.toString() ??
          json['date']?.toString() ??
          json['month']?.toString() ??
          json['year']?.toString() ??
          '',
      revenue: (json['revenue'] as num?)?.toDouble() ??
          (json['totalRevenue'] as num?)?.toDouble() ??
          0.0,
    );
  }

  RevenuePointEntity toEntity() =>
      RevenuePointEntity(label: label, revenue: revenue);
}

/// Model hứng response GET /api/dashboard/bookings/revenue
class BookingRevenueModel {
  final double totalRevenue;
  final int totalBookings;
  final List<RevenuePointModel> revenuePoints;

  const BookingRevenueModel({
    required this.totalRevenue,
    required this.totalBookings,
    required this.revenuePoints,
  });

  factory BookingRevenueModel.fromJson(Map<String, dynamic> json) {
    final List pointsRaw = json['revenuePoints'] as List? ??
        json['data'] as List? ??
        json['items'] as List? ??
        [];
    return BookingRevenueModel(
      totalRevenue:
          (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      totalBookings: (json['totalBookings'] as num?)?.toInt() ?? 0,
      revenuePoints: pointsRaw
          .map((e) => RevenuePointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  BookingRevenueEntity toEntity() => BookingRevenueEntity(
        totalRevenue: totalRevenue,
        totalBookings: totalBookings,
        revenuePoints: revenuePoints.map((e) => e.toEntity()).toList(),
      );
}

// ─── Dashboard Order Revenue ───────────────────────────────────────────────

class TopProductModel {
  final String productId;
  final String productName;
  final String? imageUrl;
  final int totalSold;
  final double totalRevenue;

  const TopProductModel({
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.totalSold,
    required this.totalRevenue,
  });

  factory TopProductModel.fromJson(Map<String, dynamic> json) {
    return TopProductModel(
      productId: json['productId']?.toString() ?? json['id']?.toString() ?? '',
      productName: json['productName']?.toString() ?? json['name']?.toString() ?? '',
      imageUrl: json['imageUrl'] as String?,
      totalSold: (json['totalSold'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  TopProductEntity toEntity() => TopProductEntity(
        productId: productId,
        productName: productName,
        imageUrl: imageUrl,
        totalSold: totalSold,
        totalRevenue: totalRevenue,
      );
}

/// Model hứng response GET /api/dashboard/orders/revenue
class OrderRevenueModel {
  final double totalRevenue;
  final int totalOrders;
  final List<TopProductModel> topProducts;

  const OrderRevenueModel({
    required this.totalRevenue,
    required this.totalOrders,
    required this.topProducts,
  });

  factory OrderRevenueModel.fromJson(Map<String, dynamic> json) {
    final List topRaw = json['topProducts'] as List? ??
        json['topSellingProducts'] as List? ??
        [];
    return OrderRevenueModel(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      topProducts: topRaw
          .map((e) => TopProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  OrderRevenueEntity toEntity() => OrderRevenueEntity(
        totalRevenue: totalRevenue,
        totalOrders: totalOrders,
        topProducts: topProducts.map((e) => e.toEntity()).toList(),
      );
}
