import '../../repositories/i_user_repository.dart';
import '../../entities/user_entity.dart';

class GetUserByIdUseCase {
  final IUserRepository repository;
  GetUserByIdUseCase(this.repository);
  Future<UserEntity> call(String id) => repository.getById(id);
}
