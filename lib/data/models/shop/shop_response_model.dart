import '../../../domain/entities/shop_entity.dart';

class ShopResponseModel {
  final String id;
  final String shopName;
  final String address;
  final double? latitude;
  final double? longitude;

  ShopResponseModel({
    required this.id,
    required this.shopName,
    required this.address,
    this.latitude,
    this.longitude,
  });

  factory ShopResponseModel.fromJson(Map<String, dynamic> json) {
    return ShopResponseModel(
      id: json['id'] ?? '',
      shopName: json['shopName'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }

  ShopEntity toEntity() {
    return ShopEntity(
      id: id,
      shopName: shopName,
      address: address,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
