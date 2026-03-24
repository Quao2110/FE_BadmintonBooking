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
      return _parseShopsResponse(res.data);
    } on DioException catch (e) {
      // Fallback for backends that don't expose /all endpoint
      if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
        try {
          final fallbackRes = await dio.get(ApiConstants.shops);
          return _parseShopsResponse(fallbackRes.data);
        } on DioException catch (fallbackError) {
          throw _toServerException(fallbackError);
        } catch (fallbackError) {
          throw ServerException(message: fallbackError.toString());
        }
      }
      throw _toServerException(e);
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
      throw _toServerException(e);
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
      throw _toServerException(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  List<ShopResponseModel> _parseShopsResponse(dynamic data) {
    List<dynamic> rawList = const [];

    if (data is List) {
      rawList = data;
    } else if (data is Map<String, dynamic>) {
      // Wrapped API response: { isSuccess, message, result }
      final result = data['result'];
      if (result is List) {
        rawList = result;
      } else if (result is Map<String, dynamic>) {
        final items = result['items'];
        if (items is List) {
          rawList = items;
        } else {
          return [ShopResponseModel.fromJson(result)];
        }
      } else {
        // Plain single shop object
        return [ShopResponseModel.fromJson(data)];
      }
    }

    return rawList
        .whereType<Map>()
        .map((e) => ShopResponseModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  ServerException _toServerException(DioException e) {
    if (e.error is ServerException) return e.error as ServerException;
    if (e.error is UnauthorizedException) {
      return ServerException(message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    }

    final status = e.response?.statusCode;
    final data = e.response?.data;
    String? message;

    if (data is Map<String, dynamic>) {
      message = (data['message'] ?? data['title'])?.toString();
    }

    message ??= e.message;
    if (message == null || message.trim().isEmpty) {
      message = status != null
          ? 'Lỗi máy chủ (HTTP $status)'
          : 'Lỗi kết nối máy chủ';
    }

    return ServerException(message: message);
  }
}
