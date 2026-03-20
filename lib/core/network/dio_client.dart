import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage.dart';

/// Singleton Dio client với SSL bypass, timeout, base URL và JWT auto-inject
class DioClient {
  DioClient._();
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl, // getter – platform-aware
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        headers: {'Accept': 'application/json'},
      ),
    );

    // Bỏ qua lỗi SSL certificate trên máy ảo/dev
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );

    // ── Tự động gắn JWT token vào mọi request ────────────────────────
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.data is FormData) {
            options.contentType = Headers.multipartFormDataContentType;
            options.headers.remove(Headers.contentTypeHeader);
          }
          final token = await SecureStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    // Request/Response logger
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => print('[DIO] $obj'),
      ),
    );

    // Interceptor xử lý lỗi chung
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) {
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.connectionError) {
            return handler.reject(e.copyWith(error: const NetworkException()));
          }

          final statusCode = e.response?.statusCode;
          dynamic data = e.response?.data;
          String? serverMessage;

          if (data is Map) {
            serverMessage = data['message']?.toString();
          } else if (data is String && data.isNotEmpty) {
            try {
              final decoded = jsonDecode(data);
              if (decoded is Map) {
                serverMessage = decoded['message']?.toString();
              }
            } catch (_) {}
          }

          final finalMessage = serverMessage ?? 'Lỗi kết nối máy chủ';

          if (statusCode == 401) {
            return handler.reject(e.copyWith(error: UnauthorizedException(message: finalMessage)));
          }

          return handler.reject(e.copyWith(error: ServerException(message: finalMessage)));
        },
      ),
    );

    return dio;
  }
}
