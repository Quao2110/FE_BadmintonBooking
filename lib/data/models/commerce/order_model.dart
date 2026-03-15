class OrderItemModel {
  final String id;
  final String productName;
  final int quantity;
  final double unitPrice;

  const OrderItemModel({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final product = _toMap(json['product']);
    return OrderItemModel(
      id: (json['id'] ?? '').toString(),
      productName:
          (json['productName'] ??
                  json['name'] ??
                  product['productName'] ??
                  'Product')
              .toString(),
      quantity: _toInt(json['quantity']),
      unitPrice: _toDouble(json['unitPrice'] ?? json['price']),
    );
  }
}

class OrderModel {
  final String id;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final double totalAmount;
  final DateTime? createdAt;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.totalAmount,
    required this.createdAt,
    required this.items,
  });

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems =
        (json['orderDetails'] ?? json['items'] ?? <dynamic>[]) as List<dynamic>;
    return OrderModel(
      id: (json['id'] ?? json['orderId'] ?? '').toString(),
      status: (json['status'] ?? json['orderStatus'] ?? 'Pending').toString(),
      paymentStatus: (json['paymentStatus'] ?? 'Pending').toString(),
      paymentMethod: (json['paymentMethod'] ?? 'COD').toString(),
      totalAmount: _toDouble(json['totalAmount'] ?? json['total']),
      createdAt: (json['createdAt'] ?? json['orderDate']) != null
          ? DateTime.tryParse(
              (json['createdAt'] ?? json['orderDate']).toString(),
            )
          : null,
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(OrderItemModel.fromJson)
          .toList(),
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _toInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

Map<String, dynamic> _toMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return <String, dynamic>{};
}
