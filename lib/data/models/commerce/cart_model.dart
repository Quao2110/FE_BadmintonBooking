import 'cart_item_model.dart';

class CartModel {
  final String id;
  final List<CartItemModel> items;
  final double subtotal;
  final double total;

  const CartModel({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.total,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory CartModel.empty() {
    return const CartModel(id: '', items: [], subtotal: 0, total: 0);
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final rawItems =
        (json['items'] ?? json['cartItems'] ?? <dynamic>[]) as List<dynamic>;
    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map(CartItemModel.fromJson)
        .toList();

    final subtotal = _toDouble(
      json['subtotal'] ??
          json['subTotal'] ??
          json['totalAmount'] ??
          json['totalPrice'],
    );
    final total = _toDouble(
      json['total'] ?? json['grandTotal'] ?? json['totalPrice'],
      fallback: subtotal,
    );

    return CartModel(
      id: (json['id'] ?? json['cartId'] ?? '').toString(),
      items: items,
      subtotal: subtotal,
      total: total,
    );
  }
}

double _toDouble(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}
