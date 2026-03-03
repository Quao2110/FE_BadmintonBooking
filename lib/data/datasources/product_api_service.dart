import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_response.dart';
import '../../core/network/dio_client.dart';
import '../models/product/product_list_query.dart';
import '../models/product/product_list_response_model.dart';
import '../models/product/product_response_model.dart';
import '../models/product/create_product_request.dart';
import '../models/product/update_product_request.dart';

class ProductRemoteDataSource {
  final Dio dio;
  ProductRemoteDataSource({Dio? dio}) : dio = dio ?? DioClient.instance;

  Future<ApiResponse<ProductListResponseModel>> getAll(ProductListQuery query) async {
    try {
      final res = await dio.get(ApiConstants.products, queryParameters: query.toJson());
      return ApiResponse.fromJson(
        res.data,
        (json) => ProductListResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<ProductResponseModel>> getById(String id) async {
    try {
      final res = await dio.get(ApiConstants.productById(id));
      return ApiResponse.fromJson(
        res.data,
        (json) => ProductResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<ProductResponseModel>> create(CreateProductRequest request) async {
    try {
      final res = await dio.post(ApiConstants.products, data: request.toJson());
      return ApiResponse.fromJson(
        res.data,
        (json) => ProductResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi tạo sản phẩm');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<ProductResponseModel>> update(String id, UpdateProductRequest request) async {
    try {
      final res = await dio.put(ApiConstants.productById(id), data: request.toJson());
      return ApiResponse.fromJson(
        res.data,
        (json) => ProductResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi cập nhật sản phẩm');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<void>> delete(String id) async {
    try {
      final res = await dio.delete(ApiConstants.productById(id));
      return ApiResponse.fromJson(res.data, (json) => null);
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi xoá sản phẩm');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
