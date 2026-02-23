import '../datasources/auth_api_service.dart';
import '../models/auth/auth_response_model.dart';
import '../models/auth/login_request.dart';
import '../models/auth/register_request.dart';
import '../models/auth/otp_verify_request.dart';
import '../models/auth/google_login_request.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/storage/local_storage.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/helpers.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> login({required String email, required String password}) async {
    final apiResponse = await remoteDataSource.login(LoginRequest(email: email, password: password));
    if (apiResponse.isSuccess) {
      final model = apiResponse.result;
      if (model == null || model.token == null || model.token!.isEmpty) {
        throw TwoFactorRequiredException(email: model?.email ?? email);
      }
      await SecureStorage.saveToken(model.token!);
      await LocalStorage.saveUserInfo(email: model.email, fullName: model.fullName, role: model.role);
      return User(
        id: JwtHelper.getUserId(model.token!),
        email: model.email,
        fullName: model.fullName,
        role: model.role,
        token: model.token,
        avatarUrl: model.avatarUrl,
      );
    }
    throw Exception(apiResponse.message);
  }

  @override
  Future<String> register(RegisterRequest request) async {
    final apiResponse = await remoteDataSource.registerInitiate(request);
    if (apiResponse.isSuccess) return apiResponse.message ?? 'Mã xác thực đã được gửi';
    throw Exception(apiResponse.message);
  }

  @override
  Future<User> verifyOtp(OtpVerifyRequest request) async {
    final apiResponse = await remoteDataSource.verifyOtp(request);
    if (apiResponse.isSuccess && apiResponse.result != null) {
      final model = apiResponse.result!;
      if (model.token != null) {
        await SecureStorage.saveToken(model.token!);
        await LocalStorage.saveUserInfo(email: model.email, fullName: model.fullName, role: model.role);
      }
      return User(
        id: model.token != null ? JwtHelper.getUserId(model.token!) : model.userId,
        email: model.email,
        fullName: model.fullName,
        role: model.role,
        token: model.token,
        avatarUrl: model.avatarUrl,
      );
    }
    throw Exception(apiResponse.message);
  }

  @override
  Future<User> googleLogin(GoogleLoginRequest request) async {
    final apiResponse = await remoteDataSource.googleLogin(request);
    if (apiResponse.isSuccess && apiResponse.result != null) {
      final model = apiResponse.result!;
      if (model.token != null) {
        await SecureStorage.saveToken(model.token!);
        await LocalStorage.saveUserInfo(email: model.email, fullName: model.fullName, role: model.role);
      }
      return User(
        id: model.token != null ? JwtHelper.getUserId(model.token!) : model.userId,
        email: model.email,
        fullName: model.fullName,
        role: model.role,
        token: model.token,
        avatarUrl: model.avatarUrl,
      );
    }
    throw Exception(apiResponse.message);
  }

  @override
  Future<User> verify2faLogin({required String email, required String code}) async {
    final apiResponse = await remoteDataSource.verify2faLogin(email: email, code: code);
    if (apiResponse.isSuccess && apiResponse.result != null) {
      final model = apiResponse.result!;
      if (model.token != null) {
        await SecureStorage.saveToken(model.token!);
        await LocalStorage.saveUserInfo(email: model.email, fullName: model.fullName, role: model.role);
      }
      return User(
        id: model.token != null ? JwtHelper.getUserId(model.token!) : model.userId,
        email: model.email,
        fullName: model.fullName,
        role: model.role,
        token: model.token,
        avatarUrl: model.avatarUrl,
      );
    }
    throw Exception(apiResponse.message);
  }

  @override
  Future<String> registerDirect(RegisterRequest request) async {
    final apiResponse = await remoteDataSource.registerDirect(request);
    if (apiResponse.isSuccess) return apiResponse.message ?? 'Đăng ký thành công';
    throw Exception(apiResponse.message);
  }

  @override
  Future<void> logout() async {
    await SecureStorage.deleteToken();
    await LocalStorage.clearUser();
  }

  @override
  Future<bool> isLoggedIn() async => await SecureStorage.hasToken();

  @override
  Future<User?> getCurrentUser() async {
    final token = await SecureStorage.getToken();
    if (token == null) return null;
    final email = await LocalStorage.getUserEmail();
    final fullName = await LocalStorage.getUserFullName();
    final role = await LocalStorage.getUserRole();
    if (email == null) return null;
    return User(id: JwtHelper.getUserId(token), email: email, fullName: fullName, role: role, token: token);
  }
}
