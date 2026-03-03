class UpdateProductRequest {
  final String categoryId;
  final String productName;
  final String? description;
  final double price;
  final String? imageUrl;
  final int stockQuantity;
  final bool isActive;

  UpdateProductRequest({
    required this.categoryId,
    required this.productName,
    this.description,
    required this.price,
    this.imageUrl,
    required this.stockQuantity,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'productName': productName,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'stockQuantity': stockQuantity,
      'isActive': isActive,
    };
  }
}
