import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/shop/shop_response_model.dart';
import '../models/shop/update_shop_request.dart';

class ShopRemoteDataSource {
  final Dio dio;
  ShopRemoteDataSource({Dio? dio}) : dio = dio ?? DioClient.instance;

  Future<List<ShopResponseModel>> getShops() async {
    try {
      final res = await dio.get(ApiConstants.shopsAll);

      if (res.data is List) {
        final raw = res.data as List;
        return raw
            .whereType<Map>()
            .map((e) => ShopResponseModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      if (res.data is Map<String, dynamic>) {
        return [ShopResponseModel.fromJson(res.data as Map<String, dynamic>)];
      }

      return [];
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ShopResponseModel> getShopInfo() async {
    try {
      final shops = await getShops();
      if (shops.isEmpty) {
        return ShopResponseModel(
          id: 'default',
          shopName: 'Nhà Văn hóa Sinh viên TP.HCM',
          address: 'Lưu Hữu Phước, Đông Hòa, Dĩ An, Bình Dương',
          latitude: 10.875153,
          longitude: 106.800729,
        );
      }
      return shops.first;
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<double> calculateDistance(double lat, double lng) async {
    try {
      final res = await dio.get(
        ApiConstants.shopDistance,
        queryParameters: {'userLat': lat.toString(), 'userLng': lng.toString()},
      );
      return (res.data['distanceKm'] as num).toDouble();
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ShopResponseModel> updateShop(String shopId, UpdateShopRequest request) async {
    try {
      final res = await dio.put(
        ApiConstants.shopById(shopId),
        data: request.toJson(),
      );
      return ShopResponseModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
