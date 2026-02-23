import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final User user;
  const AuthSuccess({required this.user});
  @override
  List<Object?> get props => [user];
}

class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}

class AuthOtpRequired extends AuthState {
  final String email;
  final String message;
  final bool is2fa;
  const AuthOtpRequired({required this.email, this.message = 'Vui lòng kiểm tra email và nhập mã OTP', this.is2fa = false});
  @override
  List<Object?> get props => [email, message, is2fa];
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
