class CartItemModel {
  final String id;
  final String productId;
  final String productName;
  final String? categoryName;
  final String? imageUrl;
  final double unitPrice;
  final int quantity;
  final int stockQuantity;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.categoryName,
    this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.stockQuantity,
  });

  double get subtotal => unitPrice * quantity;

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      id: id,
      productId: productId,
      productName: productName,
      categoryName: categoryName,
      imageUrl: imageUrl,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
      stockQuantity: stockQuantity,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final product = _toMap(json['product']);
    final productId = (json['productId'] ?? product['id'] ?? '').toString();

    return CartItemModel(
      id: (json['id'] ?? json['cartItemId'] ?? '').toString(),
      productId: productId,
      productName: (json['productName'] ?? product['productName'] ?? 'Product')
          .toString(),
      categoryName: (json['categoryName'] ?? product['categoryName'])
          ?.toString(),
      imageUrl:
          (json['imageUrl'] ??
                  product['imageUrl'] ??
                  json['thumbnail'] ??
                  json['productImageUrl'])
              ?.toString(),
      unitPrice: _toDouble(
        json['unitPrice'] ?? json['price'] ?? product['price'],
      ),
      quantity: _toInt(json['quantity']),
      stockQuantity: _toInt(
        json['stockQuantity'] ?? json['stock'] ?? product['stockQuantity'],
      ),
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
