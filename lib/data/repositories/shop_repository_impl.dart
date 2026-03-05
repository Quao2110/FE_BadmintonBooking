import '../../domain/entities/shop_entity.dart';
import '../../domain/repositories/i_shop_repository.dart';
import '../datasources/shop_api_service.dart';

class ShopRepositoryImpl implements IShopRepository {
  final ShopRemoteDataSource remoteDataSource;

  ShopRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ShopEntity> getShopInfo() async {
    final model = await remoteDataSource.getShopInfo();
    return model.toEntity();
  }

  @override
  Future<double> calculateDistance(double lat, double lng) async {
    return await remoteDataSource.calculateDistance(lat, lng);
  }
}
