import '../../entities/product_entity.dart';
import '../../repositories/i_product_repository.dart';
import '../../../data/models/product/update_product_request.dart';

class UpdateProductUseCase {
  final IProductRepository repository;
  UpdateProductUseCase(this.repository);
  Future<ProductEntity> call(String id, UpdateProductRequest request) =>
      repository.update(id, request);
}
