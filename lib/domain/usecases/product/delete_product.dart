import '../../repositories/i_product_repository.dart';

class DeleteProductUseCase {
  final IProductRepository repository;
  DeleteProductUseCase(this.repository);
  Future<void> call(String id) => repository.delete(id);
}
