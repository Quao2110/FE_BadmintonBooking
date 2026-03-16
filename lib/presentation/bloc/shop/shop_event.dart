import 'package:equatable/equatable.dart';
import '../../../data/models/shop/update_shop_request.dart';

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

class UpdateShopEvent extends ShopEvent {
  final String shopId;
  final UpdateShopRequest request;
  const UpdateShopEvent({required this.shopId, required this.request});
  @override
  List<Object?> get props => [shopId, request];
}
