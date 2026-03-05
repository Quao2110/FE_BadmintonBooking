import 'package:equatable/equatable.dart';

abstract class ShopEvent extends Equatable {
  const ShopEvent();
  @override
  List<Object?> get props => [];
}

class LoadShopInfo extends ShopEvent {
  const LoadShopInfo();
}

class CalculateDistance extends ShopEvent {
  final double userLat;
  final double userLng;
  const CalculateDistance({required this.userLat, required this.userLng});
  @override
  List<Object?> get props => [userLat, userLng];
}
