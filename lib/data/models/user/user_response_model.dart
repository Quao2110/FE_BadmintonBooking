class UserResponseModel {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? role;
  final String? avatarUrl;
  final bool isActive;
  final bool isTwoFactorEnabled;
  final String? createdAt;

  UserResponseModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.role,
    this.avatarUrl,
    this.isActive = true,
    this.isTwoFactorEnabled = false,
    this.createdAt,
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) {
    return UserResponseModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      avatarUrl: json['avatarUrl'],
      isActive: json['isActive'] ?? true,
      isTwoFactorEnabled: json['isTwoFactorEnabled'] ?? false,
      createdAt: json['createdAt'],
    );
  }
}
