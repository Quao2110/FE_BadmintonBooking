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
    String? pickString(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
      return null;
    }

    List<dynamic>? pickList(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is List) return value;
      }
      return null;
    }

    final imagesJson = pickList([
      'productImages',
      'ProductImages',
      'images',
      'Images',
    ]);

    return ProductResponseModel(
      id: pickString(['id', 'Id']) ?? '',
      categoryId: pickString(['categoryId', 'CategoryId']) ?? '',
      categoryName: pickString(['categoryName', 'CategoryName']),
      productName:
          pickString(['productName', 'ProductName', 'name', 'Name']) ?? '',
      description: pickString(['description', 'Description']),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: pickString([
        'imageUrl',
        'ImageUrl',
        'url',
        'Url',
        'path',
        'Path',
      ]),
      stockQuantity: json['stockQuantity'] ?? 0,
      isActive: json['isActive'] ?? false,
      productImages: imagesJson == null
          ? const []
          : imagesJson
                .map(
                  (e) => ProductImageResponseModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList(),
    );
  }
}
