class ProductImageEntity {
  final String id;
  final String productId;
  final String imageUrl;
  final bool isThumbnail;
  final String? createdAt;

  ProductImageEntity({
    required this.id,
    required this.productId,
    required this.imageUrl,
    required this.isThumbnail,
    this.createdAt,
  });
}
