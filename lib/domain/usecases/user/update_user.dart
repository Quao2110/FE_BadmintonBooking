import '../../../data/models/user/update_user_request.dart';
import '../../repositories/i_user_repository.dart';
import '../../entities/user_entity.dart';

class UpdateUserUseCase {
  final IUserRepository repository;
  UpdateUserUseCase(this.repository);
  Future<UserEntity> call(String id, UpdateUserRequest request) => repository.update(id, request);
}
