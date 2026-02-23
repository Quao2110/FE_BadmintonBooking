import '../../repositories/i_user_repository.dart';
import '../../entities/user_entity.dart';

class GetAllUsersUseCase {
  final IUserRepository repository;
  GetAllUsersUseCase(this.repository);
  Future<List<UserEntity>> call() => repository.getAll();
}
