class AuthResponseModel {
  final String? token;
  final String? fullName;
  final String email;
  final String? role;
  final String? userId;
  final String? avatarUrl;
  final String? message;
  final bool requires2fa;

  AuthResponseModel({
    this.token,
    this.fullName,
    required this.email,
    this.role,
    this.userId,
    this.avatarUrl,
    this.message,
    this.requires2fa = false,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'],
      fullName: json['fullName'],
      email: json['email'] ?? '',
      role: json['role'],
      userId: json['userId']?.toString(),
      avatarUrl: json['avatarUrl'],
      message: json['message'],
      requires2fa: json['requires2fa'] ?? false,
    );
  }
}
