import '../datasources/user_api_service.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user/update_user_request.dart';
import '../models/user/create_user_request.dart';
import '../models/user/user_response_model.dart';
import '../models/user/change_password_request.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../../core/storage/local_storage.dart';

class UserRepository implements IUserRepository {
  final UserRemoteDataSource _dataSource;
  UserRepository({UserRemoteDataSource? dataSource})
    : _dataSource = dataSource ?? UserRemoteDataSource();

  @override
  Future<UserEntity> create(CreateUserRequest request) async {
    final res = await _dataSource.create(request);
    if (res.isSuccess && res.result != null) {
      final m = res.result!;
      return _mapToEntity(m);
    }
    throw Exception(res.message);
  }

  @override
  Future<List<UserEntity>> getAll() async {
    final res = await _dataSource.getAll();
    if (res.isSuccess && res.result != null) {
      return res.result!.map((m) => _mapToEntity(m)).toList();
    }
    throw Exception(res.message);
  }

  @override
  Future<UserEntity> getById(String id) async {
    final res = await _dataSource.getById(id);
    if (res.isSuccess && res.result != null) {
      return _mapToEntity(res.result!);
    }
    throw Exception(res.message);
  }

  @override
  Future<UserEntity> update(String id, UpdateUserRequest request) async {
    final res = await _dataSource.update(id, request);
    if (res.isSuccess && res.result != null) {
      final m = res.result!;
      await LocalStorage.saveUserInfo(
        email: m.email,
        fullName: m.fullName,
        role: m.role,
      );
      return _mapToEntity(m);
    }
    throw Exception(res.message);
  }

  @override
  Future<String> uploadAvatar(String id, XFile imageFile) async {
    final res = await _dataSource.uploadAvatar(id, imageFile);
    if (res.isSuccess && res.result != null) {
      return res.result!;
    }
    throw Exception(res.message);
  }

  @override
  Future<void> changePassword(String id, ChangePasswordRequest request) async {
    final res = await _dataSource.changePassword(id, request);
    if (!res.isSuccess) throw Exception(res.message);
  }

  @override
  Future<void> delete(String id) async {
    final res = await _dataSource.delete(id);
    if (!res.isSuccess) throw Exception(res.message);
  }

  UserEntity _mapToEntity(UserResponseModel m) {
    return UserEntity(
      id: m.id,
      email: m.email,
      fullName: m.fullName,
      phoneNumber: m.phoneNumber,
      role: m.role,
      avatarUrl: m.avatarUrl,
      isActive: m.isActive,
      isTwoFactorEnabled: m.isTwoFactorEnabled,
      createdAt: m.createdAt,
    );
  }
}
