import '../../entities/category_entity.dart';
import '../../repositories/i_category_repository.dart';
import '../../../data/models/category/update_category_request.dart';

class UpdateCategoryUseCase {
  final ICategoryRepository repository;
  UpdateCategoryUseCase(this.repository);
  Future<CategoryEntity> call(String id, UpdateCategoryRequest request) => repository.update(id, request);
}
