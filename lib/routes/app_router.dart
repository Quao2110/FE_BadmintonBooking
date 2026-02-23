import 'package:flutter/material.dart';
import '../domain/entities/user.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/register_page.dart';
import '../presentation/pages/auth/otp_verify_page.dart';
import '../presentation/pages/auth/home_screen.dart';
import '../presentation/pages/user/profile_page.dart';
import '../presentation/pages/admin/admin_users_page.dart';

/// Tên các route trong app
class AppRoutes {
  AppRoutes._();

  static const String login    = '/login';
  static const String register = '/register';
  static const String otpVerify = '/otp-verify';
  static const String home     = '/home';
  static const String profile  = '/profile';
  static const String admin    = '/admin/users';
}

/// Tham số truyền qua route
class OtpVerifyArgs {
  final String email;
  final bool is2fa;
  const OtpVerifyArgs({required this.email, this.is2fa = false});
}

class HomeArgs {
  final User user;
  const HomeArgs(this.user);
}

class ProfileArgs {
  final String userId;
  const ProfileArgs(this.userId);
}

/// Router trung tâm – dùng onGenerateRoute trong MaterialApp
class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return _slide(const LoginScreen());

      case AppRoutes.register:
        return _slide(const RegisterScreen());

      case AppRoutes.otpVerify:
        final args = settings.arguments as OtpVerifyArgs?;
        return _slide(OtpVerifyPage(
          email: args?.email ?? '',
          is2fa: args?.is2fa ?? false,
        ));

      case AppRoutes.home:
        final args = settings.arguments as HomeArgs?;
        if (args == null) return _slide(const LoginScreen());
        return _fade(HomeScreen(user: args.user));

      case AppRoutes.profile:
        final args = settings.arguments as ProfileArgs?;
        if (args == null) return _slide(const LoginScreen());
        return _slide(ProfilePage(userId: args.userId));

      case AppRoutes.admin:
        return _slide(const AdminUsersPage());

      default:
        return _slide(const LoginScreen());
    }
  }

  // Slide từ phải sang trái
  static PageRouteBuilder _slide(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 250),
      );

  // Fade (cho màn hình chính)
  static PageRouteBuilder _fade(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      );
}
