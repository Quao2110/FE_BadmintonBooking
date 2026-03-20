import '../../data/models/user/create_user_request.dart';
import '../../data/models/user/update_user_request.dart';
import '../../data/models/user/change_password_request.dart';
import 'package:image_picker/image_picker.dart';
import '../entities/user_entity.dart';

abstract class IUserRepository {
  Future<UserEntity> create(CreateUserRequest request);
  Future<List<UserEntity>> getAll();
  Future<UserEntity> getById(String id);
  Future<UserEntity> update(String id, UpdateUserRequest request);
  Future<String> uploadAvatar(String id, XFile imageFile);
  Future<void> changePassword(String id, ChangePasswordRequest request);
  Future<void> delete(String id);
}
