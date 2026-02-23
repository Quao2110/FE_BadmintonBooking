class ApiResponse<T> {
  final bool isSuccess;
  final String message;
  final T? result;

  ApiResponse({
    required this.isSuccess,
    required this.message,
    this.result,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Object? json)? fromJsonT
      ) {
    return ApiResponse<T>(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      result: json['result'] != null && fromJsonT != null
          ? fromJsonT(json['result'])
          : null,
    );
  }
}