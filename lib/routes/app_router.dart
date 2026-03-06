import 'package:flutter/material.dart';
import '../domain/entities/user.dart';
import '../domain/entities/product_entity.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/register_page.dart';
import '../presentation/pages/auth/otp_verify_page.dart';
import '../presentation/pages/auth/home_screen.dart';
import '../presentation/pages/user/profile_page.dart';
import '../presentation/pages/admin/admin_users_page.dart';
import '../presentation/pages/admin/admin_dashboard_page.dart';
import '../presentation/pages/admin/admin_courts_page.dart';
import '../presentation/pages/admin/admin_products_page.dart';
import '../presentation/pages/admin/admin_shop_page.dart';
import '../presentation/pages/store/product_list_page.dart';
import '../presentation/pages/store/product_detail_page.dart';
import '../presentation/pages/store/service_list_page.dart';
import '../presentation/pages/store/service_detail_page.dart';
import '../presentation/pages/user/notification_page.dart';
import '../presentation/pages/booking/booking_page.dart';
import '../presentation/pages/booking/booking_history_page.dart';
import '../presentation/pages/court/court_list_page.dart';
import '../presentation/pages/court/court_detail_page.dart';
import '../presentation/pages/error/not_found_page.dart';
import '../presentation/pages/error/forbidden_page.dart';

/// Tên các route trong app
class AppRoutes {
  AppRoutes._();

  static const String login    = '/login';
  static const String register = '/register';
  static const String otpVerify = '/otp-verify';
  static const String home     = '/home';
  static const String profile  = '/profile';
  static const String admin    = '/admin/users';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminCourts = '/admin/courts';
  static const String adminProducts = '/admin/products';
  static const String adminShop = '/admin/shop';
  static const String storeList = '/store';
  static const String storeDetail = '/store/detail';
  static const String serviceList = '/store/services';
  static const String serviceDetail = '/store/services/detail';
  static const String notifications = '/notifications';
  static const String booking = '/booking';
  static const String bookingHistory = '/booking/history';
  static const String courtList = '/courts';
  static const String courtDetail = '/court-detail';
  static const String notFound = '/404';
  static const String forbidden = '/403';
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

class ProductDetailArgs {
  final ProductEntity product;
  const ProductDetailArgs(this.product);
}

class ServiceDetailArgs {
  final String serviceId;
  const ServiceDetailArgs(this.serviceId);
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

      // ── Admin Routes với Router Guard ──────────────────────────
      case AppRoutes.adminDashboard:
        final user = settings.arguments as User?;
        if (user == null || !checkAdminAccess(user)) {
          return _slide(const ForbiddenPage());
        }
        return _fade(AdminDashboardPage(user: user));

      case AppRoutes.admin:
        final user = settings.arguments as User?;
        if (user == null || !checkAdminAccess(user)) {
          return _slide(const ForbiddenPage());
        }
        return _slide(AdminUsersPage(user: user));

      case AppRoutes.adminCourts:
        final user = settings.arguments as User?;
        if (user == null || !checkAdminAccess(user)) {
          return _slide(const ForbiddenPage());
        }
        return _fade(AdminCourtsPage(user: user));

      case AppRoutes.adminProducts:
        final user = settings.arguments as User?;
        if (user == null || !checkAdminAccess(user)) {
          return _slide(const ForbiddenPage());
        }
        return _fade(AdminProductsPage(user: user));

      case AppRoutes.adminShop:
        final user = settings.arguments as User?;
        if (user == null || !checkAdminAccess(user)) {
          return _slide(const ForbiddenPage());
        }
        return _fade(AdminShopPage(user: user));

      case AppRoutes.storeList:
        return _slide(const ProductListPage());

      case AppRoutes.storeDetail:
        final args = settings.arguments as ProductDetailArgs?;
        if (args == null) return _slide(const ProductListPage());
        return _slide(ProductDetailPage(product: args.product));

      case AppRoutes.serviceList:
        return _slide(const ServiceListPage());

      case AppRoutes.serviceDetail:
        final args = settings.arguments as ServiceDetailArgs?;
        if (args == null) return _slide(const ServiceListPage());
        return _slide(ServiceDetailPage(serviceId: args.serviceId));

      case AppRoutes.notifications:
        return _slide(const NotificationPage());

      case AppRoutes.booking:
        final initialCourtId = settings.arguments as String?;
        return _slide(BookingPage(initialCourtId: initialCourtId));

      case AppRoutes.bookingHistory:
        return _slide(const BookingHistoryPage());

      case AppRoutes.courtList:
        return _slide(const CourtListPage());

      case AppRoutes.courtDetail:
        final courtId = settings.arguments as String?;
        if (courtId == null) return _slide(const CourtListPage());
        return _slide(CourtDetailPage(courtId: courtId));

      case AppRoutes.notFound:
        return _slide(const NotFoundPage());

      case AppRoutes.forbidden:
        return _slide(const ForbiddenPage());

      default:
        // Route không tồn tại -> hiển thị trang 404
        return _slide(const NotFoundPage());
    }
  }

  /// Kiểm tra quyền truy cập Admin
  /// Trả về true nếu user có quyền Admin
  static bool checkAdminAccess(User? user) {
    if (user == null) return false;
    return user.role?.toLowerCase() == 'admin';
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
