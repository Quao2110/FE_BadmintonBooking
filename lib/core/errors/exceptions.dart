/// Custom exceptions cho lớp Data
class ServerException implements Exception {
  final String message;
  const ServerException({required this.message});
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.'});
  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Lỗi đọc/ghi dữ liệu cục bộ.'});
  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException({this.message = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.'});
  @override
  String toString() => message;
}

/// Server yêu cầu xác thực 2FA – login trả về không có token
class TwoFactorRequiredException implements Exception {
  final String email;
  const TwoFactorRequiredException({required this.email});
  @override
  String toString() => 'TwoFactorRequired:$email';
}
