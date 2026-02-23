import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_response.dart';
import '../../core/network/dio_client.dart';
import '../models/auth/auth_response_model.dart';
import '../models/auth/login_request.dart';
import '../models/auth/register_request.dart';
import '../models/auth/otp_verify_request.dart';
import '../models/auth/google_login_request.dart';

class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource({Dio? dio}) : dio = dio ?? DioClient.instance;

  Future<ApiResponse<AuthResponseModel>> login(LoginRequest request) async {
    try {
      final response = await dio.post(ApiConstants.login, data: request.toJson());
      return ApiResponse.fromJson(response.data, (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<String>> registerInitiate(RegisterRequest request) async {
    try {
      final response = await dio.post(ApiConstants.registerInitiate, data: request.toJson());
      return ApiResponse.fromJson(response.data, (json) => json?.toString() ?? '');
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<AuthResponseModel>> verifyOtp(OtpVerifyRequest request) async {
    try {
      final response = await dio.post(ApiConstants.registerVerify, data: request.toJson());
      return ApiResponse.fromJson(response.data, (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi xác thực OTP');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<AuthResponseModel>> googleLogin(GoogleLoginRequest request) async {
    try {
      final response = await dio.post(ApiConstants.googleLogin, data: request.toJson());
      return ApiResponse.fromJson(response.data, (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi đăng nhập Google');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<AuthResponseModel>> verify2faLogin({required String email, required String code}) async {
    try {
      final response = await dio.post(ApiConstants.verify2faLogin, data: {'email': email, 'otp': code});
      return ApiResponse.fromJson(response.data, (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi xác thực 2FA');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<String>> registerDirect(RegisterRequest request) async {
    try {
      final response = await dio.post(ApiConstants.registerDirect, data: request.toJson());
      return ApiResponse.fromJson(response.data, (json) => json?.toString() ?? '');
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi đăng ký trực tiếp');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
