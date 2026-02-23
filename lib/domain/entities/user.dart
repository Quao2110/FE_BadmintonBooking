/// Auth User entity (domain layer)
class User {
  final String? id;
  final String email;
  final String? fullName;
  final String? role;
  final String? token;
  final String? avatarUrl;

  const User({this.id, required this.email, this.fullName, this.role, this.token, this.avatarUrl});
}
