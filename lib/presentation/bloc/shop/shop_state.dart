import 'package:equatable/equatable.dart';
import '../../../domain/entities/shop_entity.dart';

abstract class ShopState extends Equatable {
  const ShopState();
  @override
  List<Object?> get props => [];
}

class ShopInitial extends ShopState {
  final double? userLat;
  final double? userLng;
  const ShopInitial({this.userLat, this.userLng});
  @override
  List<Object?> get props => [userLat, userLng];
}

class ShopLoading extends ShopState {
  final double? userLat;
  final double? userLng;
  const ShopLoading({this.userLat, this.userLng});
  @override
  List<Object?> get props => [userLat, userLng];
}

class ShopLoaded extends ShopState {
  final ShopEntity shop;
  final double? distance;
  final double? userLat;
  final double? userLng;

  const ShopLoaded({
    required this.shop,
    this.distance,
    this.userLat,
    this.userLng,
  });

  @override
  List<Object?> get props => [shop, distance, userLat, userLng];

  ShopLoaded copyWith({
    ShopEntity? shop,
    double? distance,
    double? userLat,
    double? userLng,
  }) {
    return ShopLoaded(
      shop: shop ?? this.shop,
      distance: distance ?? this.distance,
      userLat: userLat ?? this.userLat,
      userLng: userLng ?? this.userLng,
    );
  }
}

class ShopError extends ShopState {
  final String message;
  const ShopError({required this.message});
  @override
  List<Object?> get props => [message];
}

class ShopUpdating extends ShopState {
  const ShopUpdating();
}

class ShopUpdateSuccess extends ShopState {
  final ShopEntity shop;
  final String message;
  const ShopUpdateSuccess({required this.shop, required this.message});
  @override
  List<Object?> get props => [shop, message];
}
