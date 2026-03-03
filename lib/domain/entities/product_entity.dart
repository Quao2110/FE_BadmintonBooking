import 'product_image_entity.dart';

class ProductEntity {
  final String id;
  final String categoryId;
  final String? categoryName;
  final String productName;
  final String? description;
  final double price;
  final String? imageUrl;
  final int stockQuantity;
  final bool isActive;
  final List<ProductImageEntity> productImages;

  ProductEntity({
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
}
