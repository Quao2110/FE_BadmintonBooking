import '../../data/models/auth/register_request.dart';
import '../../data/models/auth/otp_verify_request.dart';
import '../../data/models/auth/google_login_request.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<String> register(RegisterRequest request);
  Future<String> registerDirect(RegisterRequest request);
  Future<User> verifyOtp(OtpVerifyRequest request);
  Future<User> googleLogin(GoogleLoginRequest request);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<User?> getCurrentUser();
}
