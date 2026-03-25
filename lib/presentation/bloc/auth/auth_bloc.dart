import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../data/datasources/auth_api_service.dart';
import '../../../data/models/auth/otp_verify_request.dart';
import '../../../data/models/auth/google_login_request.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/usecases/auth/login.dart';
import '../../../domain/usecases/auth/register.dart';
import '../../../domain/usecases/auth/logout.dart';
import '../../../core/errors/exceptions.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepositoryImpl repository;

  static bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  final GoogleSignIn? _googleSignIn =
      (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
          ? GoogleSignIn(
              scopes: ['email', 'profile'],
              // Web Client ID: Dùng để lấy idToken
              serverClientId: '76720198371-0srmn1e9gddi9naqkpe3htme41v4lags.apps.googleusercontent.com',
              // Android Client ID: Dùng để định danh app trên Android (nếu auto-detect lỗi)
              clientId: '76720198371-jrrlvuqua37vdvf6r01mbnhum3stk2rk.apps.googleusercontent.com',
            )
          : null;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.repository,
  }) : super(const AuthInitial()) {
    on<CheckAuthEvent>(_onCheckAuth);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<Verify2faLoginEvent>(_onVerify2faLogin);
    on<GoogleLoginEvent>(_onGoogleLogin);
    on<LogoutEvent>(_onLogout);
    on<UpdateAuthUserEvent>(_onUpdateUser);
  }

  void _onUpdateUser(UpdateAuthUserEvent event, Emitter<AuthState> emit) {
    emit(AuthSuccess(user: event.user));
  }

  Future<void> _onCheckAuth(CheckAuthEvent event, Emitter<AuthState> emit) async {
    final user = await repository.getCurrentUser();
    if (user != null) emit(AuthSuccess(user: user)); else emit(const AuthLoggedOut());
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await loginUseCase(email: event.email, password: event.password);
      emit(AuthSuccess(user: user));
    } on TwoFactorRequiredException catch (e) {
      emit(AuthOtpRequired(email: e.email, message: 'Mã xác thực 2 bước đã được gửi tới ${e.email}', is2fa: true));
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onVerify2faLogin(Verify2faLoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await repository.verify2faLogin(email: event.email, code: event.code);
      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final message = await registerUseCase(event.request);
      emit(AuthOtpRequired(email: event.request.email, message: message, is2fa: false));
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await repository.verifyOtp(OtpVerifyRequest(email: event.email, otp: event.otp));
      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onGoogleLogin(GoogleLoginEvent event, Emitter<AuthState> emit) async {
    if (!_isMobile) { emit(const AuthFailure(message: 'Đăng nhập Google hiện chỉ được hỗ trợ trên thiết bị di động (Android/iOS).')); return; }
    emit(const AuthLoading());
    try {
      final googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) { emit(const AuthInitial()); return; }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) { emit(const AuthFailure(message: 'Không lấy được token Google')); return; }
      final user = await repository.googleLogin(GoogleLoginRequest(idToken: idToken));
      emit(AuthSuccess(user: user));
    } catch (e) {
      debugPrint('Google Sign-In Error Detail: $e');
      String msg;
      if (e is PlatformException) {
        if (e.code == 'network_error') {
          msg = 'Không thể kết nối Google. Vui lòng kiểm tra mạng hoặc đăng nhập bằng Email/Mật khẩu.';
        } else if (e.code == 'sign_in_canceled') {
          emit(const AuthInitial());
          return;
        } else {
          msg = 'Lỗi đăng nhập Google: ${e.message ?? e.code}';
        }
      } else {
        msg = e.toString().replaceFirst('Exception: ', '');
      }
      emit(AuthFailure(message: msg));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await logoutUseCase();
      if (_isMobile) await _googleSignIn?.signOut();
      emit(const AuthLoggedOut());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  factory AuthBloc.create() {
    final dataSource = AuthRemoteDataSource();
    final repo = AuthRepositoryImpl(remoteDataSource: dataSource);
    return AuthBloc(
      loginUseCase: LoginUseCase(repo),
      registerUseCase: RegisterUseCase(repo),
      logoutUseCase: LogoutUseCase(repo),
      repository: repo,
    );
  }
}
