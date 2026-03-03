import '../../entities/category_entity.dart';
import '../../repositories/i_category_repository.dart';

class GetAllCategoriesUseCase {
  final ICategoryRepository repository;
  GetAllCategoriesUseCase(this.repository);
  Future<List<CategoryEntity>> call() => repository.getAll();
}
