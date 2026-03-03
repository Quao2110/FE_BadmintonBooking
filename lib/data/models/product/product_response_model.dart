import 'product_image_response_model.dart';

class ProductResponseModel {
  final String id;
  final String categoryId;
  final String? categoryName;
  final String productName;
  final String? description;
  final double price;
  final String? imageUrl;
  final int stockQuantity;
  final bool isActive;
  final List<ProductImageResponseModel> productImages;

  ProductResponseModel({
    required this.id,
    required this.categoryId,
    this.categoryName,
    required this.productName,
    this.description,
    required this.price,
    this.imageUrl,
    required this.stockQuantity,
    required this.isActive,
    this.productImages = const [],
  });

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) {
    final imagesJson = json['productImages'] as List<dynamic>?;
    return ProductResponseModel(
      id: json['id']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName'],
      productName: json['productName'] ?? '',
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl'],
      stockQuantity: json['stockQuantity'] ?? 0,
      isActive: json['isActive'] ?? false,
      productImages: imagesJson == null
          ? const []
          : imagesJson
              .map((e) => ProductImageResponseModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}
