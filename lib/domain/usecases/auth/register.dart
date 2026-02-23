import '../../../data/models/auth/register_request.dart';
import '../../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);
  Future<String> call(RegisterRequest request) => repository.register(request);
}
