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
    String pickString(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
      return fallback;
    }

    double? pickDouble(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        if (value is num) return value.toDouble();
        if (value is String) {
          final parsed = double.tryParse(value.trim());
          if (parsed != null) return parsed;
        }
      }
      return null;
    }

    return ShopResponseModel(
      id: pickString(['id', 'Id']),
      shopName: pickString(['shopName', 'ShopName', 'name', 'Name']),
      address: pickString(['address', 'Address']),
      latitude: pickDouble(['latitude', 'Latitude', 'lat', 'Lat']),
      longitude: pickDouble(['longitude', 'Longitude', 'lng', 'Lng', 'lon', 'Lon']),
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
