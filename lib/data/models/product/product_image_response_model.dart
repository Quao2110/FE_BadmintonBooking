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
    String? pickString(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
      return null;
    }

    bool pickBool(List<String> keys, {bool fallback = false}) {
      for (final key in keys) {
        final value = json[key];
        if (value is bool) return value;
        if (value is num) return value != 0;
        if (value is String) {
          final text = value.toLowerCase().trim();
          if (text == 'true' || text == '1') return true;
          if (text == 'false' || text == '0') return false;
        }
      }
      return fallback;
    }

    return ProductImageResponseModel(
      id: pickString(['id', 'Id']) ?? '',
      productId: pickString(['productId', 'ProductId']) ?? '',
      imageUrl:
          pickString(['imageUrl', 'ImageUrl', 'url', 'Url', 'path', 'Path']) ??
          '',
      isThumbnail: pickBool(['isThumbnail', 'IsThumbnail']),
      createdAt: pickString(['createdAt', 'CreatedAt']),
    );
  }
}
