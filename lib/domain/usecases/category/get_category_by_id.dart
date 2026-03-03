import '../../entities/category_entity.dart';
import '../../repositories/i_category_repository.dart';

class GetCategoryByIdUseCase {
  final ICategoryRepository repository;
  GetCategoryByIdUseCase(this.repository);
  Future<CategoryEntity> call(String id) => repository.getById(id);
}
