import '../../repositories/i_user_repository.dart';

class DeleteUserUseCase {
  final IUserRepository repository;
  DeleteUserUseCase(this.repository);
  Future<void> call(String id) => repository.delete(id);
}
