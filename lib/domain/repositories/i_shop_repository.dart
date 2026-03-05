import '../../domain/entities/shop_entity.dart';

abstract class IShopRepository {
  Future<ShopEntity> getShopInfo();
  Future<double> calculateDistance(double lat, double lng);
}
