import '../../entities/product_entity.dart';
import '../../repositories/i_product_repository.dart';

class GetProductByIdUseCase {
  final IProductRepository repository;
  GetProductByIdUseCase(this.repository);
  Future<ProductEntity> call(String id) => repository.getById(id);
}
