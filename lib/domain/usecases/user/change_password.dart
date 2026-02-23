import '../../../data/models/user/change_password_request.dart';
import '../../repositories/i_user_repository.dart';

class ChangePasswordUseCase {
  final IUserRepository repository;
  ChangePasswordUseCase(this.repository);
  Future<void> call(String id, ChangePasswordRequest request) => repository.changePassword(id, request);
}
