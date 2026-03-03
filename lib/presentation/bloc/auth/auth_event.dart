import 'package:equatable/equatable.dart';
import '../../../data/models/auth/register_request.dart';
import '../../../domain/entities/user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  const LoginEvent({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final RegisterRequest request;
  const RegisterEvent({required this.request});
  @override
  List<Object?> get props => [request];
}

class VerifyOtpEvent extends AuthEvent {
  final String email;
  final String otp;
  const VerifyOtpEvent({required this.email, required this.otp});
  @override
  List<Object?> get props => [email, otp];
}

class Verify2faLoginEvent extends AuthEvent {
  final String email;
  final String code;
  const Verify2faLoginEvent({required this.email, required this.code});
  @override
  List<Object?> get props => [email, code];
}

class GoogleLoginEvent extends AuthEvent {
  const GoogleLoginEvent();
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class CheckAuthEvent extends AuthEvent {
  const CheckAuthEvent();
}

class UpdateAuthUserEvent extends AuthEvent {
  final User user;
  const UpdateAuthUserEvent(this.user);
  @override
  List<Object?> get props => [user];
}
