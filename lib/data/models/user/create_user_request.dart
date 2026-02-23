import 'package:dio/dio.dart';

class CreateUserRequest {
  final String fullName;
  final String email;
  final String password;
  final String? phoneNumber;
  final String role;
  final String? avatarPath;

  CreateUserRequest({
    required this.fullName,
    required this.email,
    required this.password,
    this.phoneNumber,
    this.role = 'Customer',
    this.avatarPath,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'role': role,
      };

  Future<FormData> toFormData() async {
    final formData = FormData.fromMap({
      'fullName': fullName,
      'email': email,
      'password': password,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      'role': role,
    });

    if (avatarPath != null && avatarPath!.isNotEmpty) {
      formData.files.add(MapEntry(
        'Avatar',
        await MultipartFile.fromFile(avatarPath!, filename: avatarPath!.split('/').last),
      ));
    }

    return formData;
  }
}
