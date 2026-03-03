import 'product_response_model.dart';

class ProductListResponseModel {
  final List<ProductResponseModel> items;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  ProductListResponseModel({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  factory ProductListResponseModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? const [];
    return ProductListResponseModel(
      items: itemsJson
          .map((e) => ProductResponseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 0,
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}
