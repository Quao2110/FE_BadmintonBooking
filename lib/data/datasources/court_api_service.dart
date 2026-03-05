import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/court/court_response_model.dart';

class CourtRemoteDataSource {
  final Dio dio;
  CourtRemoteDataSource({Dio? dio}) : dio = dio ?? DioClient.instance;

  /// Lấy danh sách tất cả sân
  Future<List<CourtResponseModel>> getAll() async {
    try {
      final res = await dio.get(ApiConstants.courts);
      final data = res.data as List? ?? [];
      return data.map((e) => CourtResponseModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Lấy thông tin sân theo id
  Future<CourtResponseModel> getById(String id) async {
    try {
      final res = await dio.get(ApiConstants.courtById(id));
      return CourtResponseModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
