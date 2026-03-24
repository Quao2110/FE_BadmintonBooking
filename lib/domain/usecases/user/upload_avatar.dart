import 'package:image_picker/image_picker.dart';
import '../../repositories/i_user_repository.dart';

class UploadAvatarUseCase {
  final IUserRepository repository;
  UploadAvatarUseCase(this.repository);

  Future<String> call(String userId, XFile imageFile) {
    return repository.uploadAvatar(userId, imageFile);
  }
}
