class UserEntity {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? role;
  final String? avatarUrl;
  final bool isActive;
  final bool isTwoFactorEnabled;
  final String? createdAt;

  UserEntity({
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
}
