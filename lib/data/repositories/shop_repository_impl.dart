import '../../domain/entities/shop_entity.dart';
import '../../domain/repositories/i_shop_repository.dart';
import '../datasources/shop_api_service.dart';
import '../models/shop/update_shop_request.dart';

class ShopRepositoryImpl implements IShopRepository {
  final ShopRemoteDataSource remoteDataSource;

  ShopRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ShopEntity>> getShops() async {
    final models = await remoteDataSource.getShops();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<ShopEntity> getShopInfo() async {
    final model = await remoteDataSource.getShopInfo();
    return model.toEntity();
  }

  @override
  Future<double> calculateDistance(double lat, double lng) async {
    return await remoteDataSource.calculateDistance(lat, lng);
  }

  @override
  Future<ShopEntity> updateShop(String shopId, UpdateShopRequest request) async {
    final model = await remoteDataSource.updateShop(shopId, request);
    return model.toEntity();
  }
}
