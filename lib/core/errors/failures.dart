import 'package:equatable/equatable.dart';

/// Base failure class - dùng ở Domain layer
abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Lỗi kết nối mạng.'});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Lỗi dữ liệu cục bộ.'});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'Phiên đăng nhập hết hạn.'});
}
