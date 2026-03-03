import '../../entities/product_entity.dart';
import '../../repositories/i_product_repository.dart';
import '../../../data/models/product/product_list_query.dart';

class GetProductsUseCase {
  final IProductRepository repository;
  GetProductsUseCase(this.repository);
  Future<List<ProductEntity>> call(ProductListQuery query) => repository.getAll(query);
}
