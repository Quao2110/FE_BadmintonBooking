import '../../domain/entities/shop_entity.dart';
import '../../data/models/shop/update_shop_request.dart';

abstract class IShopRepository {
  Future<List<ShopEntity>> getShops();
  Future<ShopEntity> getShopInfo();
  Future<double> calculateDistance(double lat, double lng);
  Future<ShopEntity> updateShop(String shopId, UpdateShopRequest request);
}
