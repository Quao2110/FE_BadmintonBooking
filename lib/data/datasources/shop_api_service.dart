import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/shop/shop_response_model.dart';

class ShopRemoteDataSource {
  final Dio dio;
  ShopRemoteDataSource({Dio? dio}) : dio = dio ?? DioClient.instance;

  Future<ShopResponseModel> getShopInfo() async {
    try {
      final res = await dio.get(ApiConstants.shops);
      // Backend returns a single shop or a list, based on the controller GetShopInfo
      // var result = await _shopService.GetShopInfoAsync();
      // If it's a list, we take the first one.
      if (res.data is List) {
        if ((res.data as List).isEmpty) {
          return ShopResponseModel(
            id: 'default',
            shopName: 'Nhà Văn hóa Sinh viên TP.HCM',
            address: 'Lưu Hữu Phước, Đông Hòa, Dĩ An, Bình Dương',
            latitude: 10.875153,
            longitude: 106.800729,
          );
        }
        return ShopResponseModel.fromJson(res.data[0] as Map<String, dynamic>);
      }
      if (res.data == null) {
        return ShopResponseModel(
          id: 'default',
          shopName: 'Nhà Văn hóa Sinh viên TP.HCM',
          address: 'Lưu Hữu Phước, Đông Hòa, Dĩ An, Bình Dương',
          latitude: 10.875153,
          longitude: 106.800729,
        );
      }
      return ShopResponseModel.fromJson(res.data as Map<String, dynamic>);
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
}
