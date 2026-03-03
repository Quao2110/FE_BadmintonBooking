import '../../entities/product_entity.dart';
import '../../repositories/i_product_repository.dart';
import '../../../data/models/product/create_product_request.dart';

class CreateProductUseCase {
  final IProductRepository repository;
  CreateProductUseCase(this.repository);
  Future<ProductEntity> call(CreateProductRequest request) => repository.create(request);
}
