class ProductImageResponseModel {
  final String id;
  final String productId;
  final String imageUrl;
  final bool isThumbnail;
  final String? createdAt;

  ProductImageResponseModel({
    required this.id,
    required this.productId,
    required this.imageUrl,
    required this.isThumbnail,
    this.createdAt,
  });

  factory ProductImageResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductImageResponseModel(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isThumbnail: json['isThumbnail'] ?? false,
      createdAt: json['createdAt'],
    );
  }
}
