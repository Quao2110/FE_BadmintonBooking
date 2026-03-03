import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_response.dart';
import '../../core/network/dio_client.dart';
import '../models/category/category_response_model.dart';
import '../models/category/create_category_request.dart';
import '../models/category/update_category_request.dart';

class CategoryRemoteDataSource {
  final Dio dio;
  CategoryRemoteDataSource({Dio? dio}) : dio = dio ?? DioClient.instance;

  Future<ApiResponse<List<CategoryResponseModel>>> getAll() async {
    try {
      final res = await dio.get(ApiConstants.categories);
      return ApiResponse.fromJson(
        res.data,
        (json) => (json as List)
            .map((e) => CategoryResponseModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<CategoryResponseModel>> getById(String id) async {
    try {
      final res = await dio.get(ApiConstants.categoryById(id));
      return ApiResponse.fromJson(
        res.data,
        (json) => CategoryResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<CategoryResponseModel>> create(CreateCategoryRequest request) async {
    try {
      final res = await dio.post(ApiConstants.categories, data: request.toJson());
      return ApiResponse.fromJson(
        res.data,
        (json) => CategoryResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi tạo danh mục');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<CategoryResponseModel>> update(String id, UpdateCategoryRequest request) async {
    try {
      final res = await dio.put(ApiConstants.categoryById(id), data: request.toJson());
      return ApiResponse.fromJson(
        res.data,
        (json) => CategoryResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi cập nhật danh mục');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<void>> delete(String id) async {
    try {
      final res = await dio.delete(ApiConstants.categoryById(id));
      return ApiResponse.fromJson(res.data, (json) => null);
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi xoá danh mục');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
