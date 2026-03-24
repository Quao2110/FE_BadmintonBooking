import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class UpdateUserRequest {
  final String? userId;
  final String fullName;
  final String? phoneNumber;
  final String? avatarPath;
  final XFile? imageFile;
  final String? role;
  final bool? isActive;

  UpdateUserRequest({
    this.userId,
    required this.fullName,
    this.phoneNumber,
    this.avatarPath,
    this.imageFile,
    this.role,
    this.isActive,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    if (phoneNumber != null) 'phoneNumber': phoneNumber,
    if (role != null) 'role': role,
    if (isActive != null) 'isActive': isActive,
  };

  Future<FormData> toFormData() async {
    final formData = FormData.fromMap({
      'fullName': fullName,
      if (phoneNumber != null && phoneNumber!.isNotEmpty)
        'phoneNumber': phoneNumber,
      if (role != null) 'role': role,
      if (isActive != null) 'isActive': isActive,
    });

    // Prioritize imageFile (XFile from picker) over avatarPath
    if (imageFile != null) {
      final avatarFile = kIsWeb
          ? MultipartFile.fromBytes(
              await imageFile!.readAsBytes(),
              filename: imageFile!.name,
            )
          : await MultipartFile.fromFile(
              imageFile!.path,
              filename: imageFile!.name,
            );
      formData.files.add(MapEntry('Avatar', avatarFile));
    } else if (avatarPath != null && avatarPath!.isNotEmpty) {
      formData.files.add(
        MapEntry(
          'Avatar',
          await MultipartFile.fromFile(
            avatarPath!,
            filename: avatarPath!.split('/').last,
          ),
        ),
      );
    }

    return formData;
  }
}
