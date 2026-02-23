import 'package:dio/dio.dart';

class UpdateUserRequest {
  final String fullName;
  final String? phoneNumber;
  final String? avatarPath;

  UpdateUserRequest({
    required this.fullName,
    this.phoneNumber,
    this.avatarPath,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
      };

  Future<FormData> toFormData() async {
    final formData = FormData.fromMap({
      'fullName': fullName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
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
