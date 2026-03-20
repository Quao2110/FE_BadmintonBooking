import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_response.dart';
import '../../core/network/dio_client.dart';
import '../models/user/user_response_model.dart';
import '../models/user/update_user_request.dart';
import '../models/user/create_user_request.dart';
import '../models/user/change_password_request.dart';

class UserRemoteDataSource {
  final Dio dio;
  UserRemoteDataSource({Dio? dio}) : dio = dio ?? DioClient.instance;

  Future<ApiResponse<UserResponseModel>> create(
    CreateUserRequest request,
  ) async {
    try {
      final data = await request.toFormData();
      final res = await dio.post(ApiConstants.users, data: data);
      return ApiResponse.fromJson(
        res.data,
        (json) => UserResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi tạo người dùng');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<List<UserResponseModel>>> getAll() async {
    try {
      final res = await dio.get(ApiConstants.users);
      return ApiResponse.fromJson(
        res.data,
        (json) => (json as List)
            .map((e) => UserResponseModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<UserResponseModel>> getById(String id) async {
    try {
      final res = await dio.get(ApiConstants.userById(id));
      return ApiResponse.fromJson(
        res.data,
        (json) => UserResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<UserResponseModel>> update(
    String id,
    UpdateUserRequest request,
  ) async {
    try {
      final data = await request.toFormData();
      final res = await dio.put(ApiConstants.userById(id), data: data);
      return ApiResponse.fromJson(
        res.data,
        (json) => UserResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi cập nhật');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<String>> uploadAvatar(String id, XFile imageFile) async {
    try {
      final formData = FormData.fromMap({
        'File': await _toMultipartFile(imageFile),
      });
      final res = await dio.post(
        ApiConstants.userUploadAvatar(id),
        data: formData,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );
      return ApiResponse.fromJson(
        res.data,
        (json) => (json as Map<String, dynamic>)['avatarUrl'] as String,
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi upload ảnh');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<MultipartFile> _toMultipartFile(XFile file) async {
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      return MultipartFile.fromBytes(bytes, filename: file.name);
    }
    return MultipartFile.fromFile(file.path, filename: file.name);
  }

  Future<ApiResponse<void>> changePassword(
    String id,
    ChangePasswordRequest request,
  ) async {
    try {
      final res = await dio.patch(
        ApiConstants.userChangePassword(id),
        data: request.toJson(),
      );
      return ApiResponse.fromJson(res.data, (json) => null);
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi đổi mật khẩu');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<void>> delete(String id) async {
    try {
      final res = await dio.delete(ApiConstants.userById(id));
      return ApiResponse.fromJson(res.data, (json) => null);
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi xoá người dùng');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
