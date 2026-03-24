import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
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
      final courts = data
          .map((e) => CourtResponseModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return courts;
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

  Future<void> uploadImage({
    required String courtId,
    required XFile imageFile,
  }) async {
    try {
      final base64Image = await _toBase64DataUri(imageFile);
      final payload = {'courtId': courtId, 'imageUrl': base64Image};
      await dio.post(ApiConstants.courtImages, data: payload);
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi tải ảnh sân');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Cập nhật sân (theo API backend hiện tại dùng POST /api/Courts)
  Future<void> updateCourt({
    required String courtId,
    required String courtName,
    String? description,
    required String status,
  }) async {
    try {
      await dio.put(
        ApiConstants.courtById(courtId),
        data: {
          'courtName': courtName,
          'description': description,
          'status': status,
        },
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi cập nhật sân');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<String> _toBase64DataUri(XFile file) async {
    final bytes = await file.readAsBytes();
    final base64 = base64Encode(bytes);
    final ext = file.name.split('.').last.toLowerCase();
    final mime = switch (ext) {
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
    return 'data:$mime;base64,$base64';
  }

}
