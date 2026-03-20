import 'package:image_picker/image_picker.dart';
import '../../repositories/i_product_repository.dart';

class UploadProductImageUseCase {
  final IProductRepository repository;
  UploadProductImageUseCase(this.repository);

  Future<void> call(
    String productId,
    XFile imageFile, {
    bool isThumbnail = false,
  }) {
    return repository.uploadImage(
      productId,
      imageFile,
      isThumbnail: isThumbnail,
    );
  }
}
