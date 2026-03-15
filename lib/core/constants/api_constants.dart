import 'dart:io';
import 'package:flutter/foundation.dart';

/// API URLs and endpoints
class ApiConstants {
  ApiConstants._();

  // Base URL
  // Android Emulator: 10.0.2.2 maps to host localhost
  // Windows/macOS/Linux/Web/iOS Simulator: use localhost
  static String get baseUrl {
    const env = String.fromEnvironment('API_BASE_URL');
    if (env.isNotEmpty) return env;
    const envScheme = String.fromEnvironment('API_SCHEME');
    final scheme = envScheme.isNotEmpty ? envScheme : 'https';
    final port = scheme == 'https' ? 7133 : 5000;
    if (!kIsWeb && Platform.isAndroid) {
      return '$scheme://10.0.2.2:$port';
    }
    return '$scheme://localhost:$port';
  }

  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String verify2faLogin = '/api/auth/login/2fa/verify';
  static const String registerInitiate = '/api/auth/register/initiate';
  static const String registerVerify = '/api/auth/register/verify';
  static const String googleLogin = '/api/auth/login/google';
  static const String registerDirect = '/api/auth/register/direct';

  // User endpoints
  static const String users = '/api/users';
  static String userById(String id) => '/api/users/$id';
  static String userUploadAvatar(String id) => '/api/users/$id/avatar';
  static String userChangePassword(String id) => '/api/users/$id/password';
  static String userByEmail(String email) => '/api/users/email/$email';

  // Category endpoints
  static const String categories = '/api/categories';
  static String categoryById(String id) => '/api/categories/$id';

  // Product endpoints
  static const String products = '/api/products';
  static String productById(String id) => '/api/products/$id';

  // Service endpoints
  static const String services = '/api/services';
  static String serviceById(String id) => '/api/services/$id';

  // Notification endpoints
  static const String notifications = '/api/Notifications';
  static String notificationsByUserId(String userId) =>
      '/api/Notifications/user/$userId';
  static String notificationMarkAsRead(String id) =>
      '/api/Notifications/mark-as-read/$id';

  // Court endpoints
  static const String courts = '/api/courts';
  static String courtById(String id) => '/api/courts/$id';

  // Shop endpoints
  static const String shops = '/api/Shops';
  static String shopById(String id) => '/api/Shops/$id';
  static const String shopDistance = '/api/Shops/distance';

  // Booking endpoints
  static const String bookings = '/api/bookings';
  static const String bookingAvailability = '/api/bookings/availability';
  static const String bookingMyHistory = '/api/bookings/my-history';
  static String bookingById(String id) => '/api/bookings/$id';
  static String bookingCancel(String id) => '/api/bookings/$id/cancel';

  // Cart endpoints
  static const String cart = '/api/cart';
  static const String cartAdd = '/api/cart/add';
  static String cartItemById(String id) => '/api/cart/item/$id';
  static const String cartClear = '/api/cart/clear';

  // Order endpoints
  static const String orderCheckout = '/api/orders/checkout';
  static const String orderMyOrders = '/api/orders/my-orders';
  static String orderById(String id) => '/api/orders/$id';

  // Payment endpoints
  static const String paymentCreateVnpayLink =
      '/api/payments/vnpay/create-link';

  // Support message endpoints
  static const String messages = '/api/inbox/messages';
  static const String messagesSend = '/api/inbox/messages';

  static String getFullImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return '';
    if (relativePath.startsWith('http')) return relativePath;
    return '${baseUrl}$relativePath';
  }

  // Timeout (milliseconds)
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
