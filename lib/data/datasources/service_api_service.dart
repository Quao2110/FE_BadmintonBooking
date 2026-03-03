import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_response.dart';
import '../../core/network/dio_client.dart';
import '../models/service/service_response_model.dart';

class ServiceRemoteDataSource {
  final Dio dio;
  ServiceRemoteDataSource({Dio? dio}) : dio = dio ?? DioClient.instance;

  Future<ApiResponse<List<ServiceResponseModel>>> getAll() async {
    try {
      final res = await dio.get(ApiConstants.services);
      return ApiResponse.fromJson(
        res.data,
        (json) => (json as List)
            .map((e) => ServiceResponseModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<ServiceResponseModel>> getById(String id) async {
    try {
      final res = await dio.get(ApiConstants.serviceById(id));
      return ApiResponse.fromJson(
        res.data,
        (json) => ServiceResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
