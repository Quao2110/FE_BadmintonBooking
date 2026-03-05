import 'package:equatable/equatable.dart';

class ShopEntity extends Equatable {
  final String id;
  final String shopName;
  final String address;
  final double? latitude;
  final double? longitude;

  const ShopEntity({
    required this.id,
    required this.shopName,
    required this.address,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [id, shopName, address, latitude, longitude];
}
