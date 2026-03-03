import '../../entities/category_entity.dart';
import '../../repositories/i_category_repository.dart';
import '../../../data/models/category/create_category_request.dart';

class CreateCategoryUseCase {
  final ICategoryRepository repository;
  CreateCategoryUseCase(this.repository);
  Future<CategoryEntity> call(CreateCategoryRequest request) => repository.create(request);
}
